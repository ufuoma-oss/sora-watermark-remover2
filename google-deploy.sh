#!/bin/bash

# Exit on any error
set -e

# --- Configuration ---
export PROJECT_ID="watermark-remover-474509"
export REGION="us-central1"
export NETWORK="watermark-remover-network"
export AR_REPO="watermark-remover"
export CONNECTOR_NAME="watermark-remover-conn"
export DB_INSTANCE_NAME="watermark-remover-db"
export REDIS_INSTANCE_NAME="watermark-remover-redis"

# --- Set Project ---
gcloud config set project $PROJECT_ID

# --- Backend Infrastructure Setup ---
echo "
--- Enabling Google Cloud APIs ---"
yes | gcloud services enable cloudbuild.googleapis.com artifactregistry.googleapis.com run.googleapis.com sqladmin.googleapis.com redis.googleapis.com compute.googleapis.com vpcaccess.googleapis.com servicenetworking.googleapis.com secretmanager.googleapis.com

# --- Create Artifact Registry Repository ---
echo "
--- Creating Artifact Registry Repository (for Docker images) ---"
gcloud artifacts repositories create $AR_REPO --repository-format=docker --location=$REGION --description="Docker repository for watermark remover" || echo "Artifact Registry repository already exists."

# --- VPC and Networking Setup ---
echo "
--- Setting up VPC Network and Connector ---"
gcloud compute networks create $NETWORK --subnet-mode=auto --bgp-routing-mode=regional || echo "Network already exists."
gcloud compute addresses create google-managed-services-$NETWORK --global --purpose=VPC_PEERING --prefix-length=16 --network=$NETWORK || echo "Address for VPC Peering already exists."
yes | gcloud services vpc-peerings connect --service=servicenetworking.googleapis.com --ranges=google-managed-services-$NETWORK --network=$NETWORK || echo "VPC Peering already connected."
gcloud compute networks vpc-access connectors create $CONNECTOR_NAME --network $NETWORK --region $REGION --range=10.8.0.0/28 || echo "VPC Connector already exists."

# --- Database (Cloud SQL) Setup ---
echo "
--- Setting up Cloud SQL (PostgreSQL) ---"
DB_PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 20)
gcloud sql instances create $DB_INSTANCE_NAME --database-version=POSTGRES_15 --region=$REGION --cpu=1 --memory=4GB --network=$NETWORK || echo "Database instance already exists."
DB_IP=$(gcloud sql instances describe $DB_INSTANCE_NAME --format='value(ipAddresses.ipAddress)')
gcloud sql users create sorawatermarks --instance=$DB_INSTANCE_NAME --password=$DB_PASSWORD || gcloud sql users set-password sorawatermarks --instance=$DB_INSTANCE_NAME --password=$DB_PASSWORD
gcloud sql databases create sorawatermarks_db --instance=$DB_INSTANCE_NAME || echo "Database already exists."
echo $DB_PASSWORD | gcloud secrets create db-password --data-file=- --project=$PROJECT_ID --replication-policy=automatic || echo "Secret already exists."
gcloud secrets add-iam-policy-binding db-password --member="serviceAccount:$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')-compute@developer.gserviceaccount.com" --role="roles/secretmanager.secretAccessor" --project=$PROJECT_ID || echo "IAM policy already exists."

# --- Redis (Memorystore) Setup ---
echo "
--- Setting up Memorystore for Redis ---"
gcloud redis instances create $REDIS_INSTANCE_NAME --size=1 --region=$REGION --tier=basic --redis-version=redis_6_x --network=$NETWORK --connect-mode=private-service-access || echo "Redis instance already exists."
REDIS_IP=$(gcloud redis instances describe $REDIS_INSTANCE_NAME --region=$REGION --format='value(host)')

# --- Backend Build using Cloud Build ---
echo "
--- Building Backend Docker Image using Google Cloud Build ---"
IMAGE_NAME="${REGION}-docker.pkg.dev/$PROJECT_ID/$AR_REPO/backend:latest"
gcloud builds submit ./backend --tag $IMAGE_NAME --project=$PROJECT_ID

# --- Deploy Backend API ---
echo "
--- Deploying Backend API to Cloud Run ---"
SECRET_KEY=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
DATABASE_URL="postgresql+asyncpg://sorawatermarks:$DB_PASSWORD@$DB_IP/sorawatermarks_db"
CELERY_BROKER_URL="redis://$REDIS_IP:6379/0"

gcloud run deploy watermark-remover-backend \
  --image $IMAGE_NAME \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --vpc-connector $CONNECTOR_NAME \
  --update-secrets=DATABASE_URL=db-password:latest \
  --set-env-vars="SECRET_KEY=$SECRET_KEY" \
  --set-env-vars="ALGORITHM=HS256" \
  --set-env-vars="ACCESS_TOKEN_EXPIRE_MINUTES=30" \
  --set-env-vars="CELERY_BROKER_URL=$CELERY_BROKER_URL" \
  --set-env-vars="CELERY_RESULT_BACKEND=$CELERY_BROKER_URL"

# --- Capture Backend URL ---
export BACKEND_URL=$(gcloud run services describe watermark-remover-backend --platform managed --region $REGION --format 'value(status.url)')
echo "
Backend deployed to: $BACKEND_URL"

# --- Celery Worker Deployment ---
echo "
--- Deploying Celery Worker to Cloud Run ---"
gcloud run deploy watermark-remover-worker \
  --image $IMAGE_NAME \
  --platform managed \
  --region $REGION \
  --vpc-connector $CONNECTOR_NAME \
  --update-secrets=DATABASE_URL=db-password:latest \
  --set-env-vars="SECRET_KEY=$SECRET_KEY" \
  --set-env-vars="CELERY_BROKER_URL=$CELERY_BROKER_URL" \
  --set-env-vars="CELERY_RESULT_BACKEND=$CELERY_BROKER_URL" \
  --command /usr/local/bin/celery \
  --args -A,app.celery_app,worker,-l,info

# --- Fully Automated Frontend Deployment ---
echo "
--- Building and Deploying Frontend with Backend URL ---"
# Generate Firebase config for the web app
gcloud_project_number=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
firebase apps:sdkconfig WEB -o frontend/src/firebase-config.js

# Build the React app, injecting the backend URL as an environment variable
(cd frontend && npm install && REACT_APP_API_URL=$BACKEND_URL npm run build)

# Deploy the newly built frontend to Firebase Hosting
firebase deploy --only hosting

echo "


--- SINGLE-CLICK DEPLOYMENT COMPLETE ---"
FRONTEND_URL=$(firebase hosting:sites:get -s | grep -o 'https://[^ ]*')
echo "Your live application is available at: $FRONTEND_URL"
