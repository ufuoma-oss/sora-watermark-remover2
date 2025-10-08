import os
import logging
from datetime import datetime, timedelta
from typing import Optional
from google.cloud import storage

logger = logging.getLogger(__name__)

class GCSService:
    def __init__(self):
        self.storage_client = storage.Client()
        self.bucket_name = os.getenv('GCS_BUCKET_NAME', 'sora-watermark-remover-storage')
        self.bucket = self.storage_client.bucket(self.bucket_name)
    
    def upload_file(self, file_path: str, gcs_key: str) -> bool:
        """Upload file to GCS"""
        try:
            blob = self.bucket.blob(gcs_key)
            blob.upload_from_filename(file_path)
            logger.info(f"File uploaded successfully: {gcs_key}")
            return True
        except Exception as e:
            logger.error(f"Error uploading file {gcs_key}: {str(e)}")
            return False
    
    def download_file(self, gcs_key: str, local_path: str) -> bool:
        """Download file from GCS"""
        try:
            blob = self.bucket.blob(gcs_key)
            blob.download_to_filename(local_path)
            logger.info(f"File downloaded successfully: {gcs_key}")
            return True
        except Exception as e:
            logger.error(f"Error downloading file {gcs_key}: {str(e)}")
            return False
    
    def generate_presigned_url(self, gcs_key: str, expiration: int = 3600) -> Optional[str]:
        """Generate presigned URL for file download"""
        try:
            blob = self.bucket.blob(gcs_key)
            url = blob.generate_signed_url(
                version="v4",
                expiration=timedelta(seconds=expiration),
                method="GET",
            )
            return url
        except Exception as e:
            logger.error(f"Error generating presigned URL for {gcs_key}: {str(e)}")
            return None
    
    def delete_file(self, gcs_key: str) -> bool:
        """Delete file from GCS"""
        try:
            blob = self.bucket.blob(gcs_key)
            blob.delete()
            logger.info(f"File deleted successfully: {gcs_key}")
            return True
        except Exception as e:
            logger.error(f"Error deleting file {gcs_key}: {str(e)}")
            return False
    
    def get_file_url(self, gcs_key: str) -> str:
        """Get public URL for file"""
        return f"https://storage.googleapis.com/{self.bucket_name}/{gcs_key}"

# Global instance
gcs_service = GCSService()
