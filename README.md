# Sora Watermark Remover

A powerful AI-powered web application for removing watermarks from TikTok, Sora, and other video content with 99%+ accuracy.

## Features

- **AI-Powered Removal**: Advanced machine learning algorithms detect and remove watermarks with high precision
- **Web-Based Platform**: No installation required, works directly in your browser
- **User Accounts**: Sign up, log in, and maintain a history of processed videos
- **Subscription Model**: $12/month or $70/year for unlimited processing
- **High Quality Output**: Maintains original video quality with no compression artifacts
- **Secure Processing**: Videos are processed securely and automatically deleted after 7 days
- **Real-time Status**: Track processing progress in real-time

## Technology Stack

### Backend
- **FastAPI**: Modern, fast web framework for building APIs
- **PostgreSQL**: Reliable database for user data and job tracking
- **Redis**: Message broker for Celery task queue
- **Celery**: Distributed task queue for video processing
- **OpenCV**: Computer vision library for video processing
- **PyTorch**: Deep learning framework for AI models
- **AWS S3**: Cloud storage for video files
- **Docker**: Containerization for easy deployment

### Frontend
- **React**: Modern JavaScript library for building user interfaces
- **Ant Design**: Professional UI component library
- **React Router**: Client-side routing
- **Axios**: HTTP client for API communication

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Node.js 18+ (for local development)
- Python 3.9+ (for local development)

### Using Docker Compose (Recommended)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd sora-watermark-remover
   ```

2. **Set up environment variables**
   ```bash
   cp backend/.env.example backend/.env
   # Edit backend/.env with your configuration
   ```

3. **Start the application**
   ```bash
   docker-compose up -d
   ```

4. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs

### Local Development

#### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

5. **Set up database**
   ```bash
   # Make sure PostgreSQL is running
   # Update DATABASE_URL in .env
   ```

6. **Run database migrations**
   ```bash
   alembic upgrade head
   ```

7. **Start the backend**
   ```bash
   python main.py
   ```

#### Frontend Setup

1. **Navigate to frontend directory**
   ```bash
   cd frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start the development server**
   ```bash
   npm start
   ```

## Configuration

### Environment Variables

Create a `.env` file in the backend directory with the following variables:

```env
# Database
DATABASE_URL=postgresql://user:password@localhost/sora_watermark_remover

# Redis
REDIS_URL=redis://localhost:6379

# JWT
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# AWS S3
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
AWS_REGION=us-east-1
S3_BUCKET_NAME=sora-watermark-remover

# Stripe
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# SendGrid
SENDGRID_API_KEY=your-sendgrid-api-key
FROM_EMAIL=noreply@sorawatermarkremover.com

# App Settings
MAX_VIDEO_SIZE_MB=500
MAX_VIDEO_DURATION_SECONDS=600
PROCESSING_TIMEOUT_SECONDS=1800
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user

### Video Processing
- `POST /api/videos/upload` - Upload video for processing
- `GET /api/jobs/{job_id}/status` - Get job status
- `GET /api/jobs` - Get user's jobs
- `GET /api/jobs/{job_id}/download` - Download processed video

### Health Check
- `GET /api/health` - Application health status

## Deployment

### Production Deployment

1. **Set up production environment variables**
2. **Configure AWS S3 bucket**
3. **Set up PostgreSQL database**
4. **Configure Redis instance**
5. **Deploy using Docker Compose or Kubernetes**

### AWS Deployment

1. **Create EC2 instance with GPU support**
2. **Set up RDS PostgreSQL database**
3. **Configure ElastiCache Redis**
4. **Set up S3 bucket**
5. **Deploy using Docker containers**

## Development

### Running Tests

```bash
# Backend tests
cd backend
pytest

# Frontend tests
cd frontend
npm test
```

### Code Quality

```bash
# Backend linting
cd backend
flake8 .
black .

# Frontend linting
cd frontend
npm run lint
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@sorawatermarkremover.com or create an issue in the repository.

## Roadmap

- [ ] Mobile app development
- [ ] Batch processing support
- [ ] Additional watermark types
- [ ] Video upscaling feature
- [ ] API rate limiting
- [ ] Advanced analytics dashboard
