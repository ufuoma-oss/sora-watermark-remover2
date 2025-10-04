import boto3
import os
from botocore.exceptions import ClientError
from typing import Optional
import logging
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

class S3Service:
    def __init__(self):
        self.s3_client = boto3.client(
            's3',
            aws_access_key_id=os.getenv('AWS_ACCESS_KEY_ID'),
            aws_secret_access_key=os.getenv('AWS_SECRET_ACCESS_KEY'),
            region_name=os.getenv('AWS_REGION', 'us-east-1')
        )
        self.bucket_name = os.getenv('S3_BUCKET_NAME', 'sora-watermark-remover')
    
    def upload_file(self, file_path: str, s3_key: str) -> bool:
        """Upload file to S3"""
        try:
            self.s3_client.upload_file(file_path, self.bucket_name, s3_key)
            logger.info(f"File uploaded successfully: {s3_key}")
            return True
        except ClientError as e:
            logger.error(f"Error uploading file {s3_key}: {str(e)}")
            return False
    
    def download_file(self, s3_key: str, local_path: str) -> bool:
        """Download file from S3"""
        try:
            self.s3_client.download_file(self.bucket_name, s3_key, local_path)
            logger.info(f"File downloaded successfully: {s3_key}")
            return True
        except ClientError as e:
            logger.error(f"Error downloading file {s3_key}: {str(e)}")
            return False
    
    def generate_presigned_url(self, s3_key: str, expiration: int = 3600) -> Optional[str]:
        """Generate presigned URL for file download"""
        try:
            response = self.s3_client.generate_presigned_url(
                'get_object',
                Params={'Bucket': self.bucket_name, 'Key': s3_key},
                ExpiresIn=expiration
            )
            return response
        except ClientError as e:
            logger.error(f"Error generating presigned URL for {s3_key}: {str(e)}")
            return None
    
    def delete_file(self, s3_key: str) -> bool:
        """Delete file from S3"""
        try:
            self.s3_client.delete_object(Bucket=self.bucket_name, Key=s3_key)
            logger.info(f"File deleted successfully: {s3_key}")
            return True
        except ClientError as e:
            logger.error(f"Error deleting file {s3_key}: {str(e)}")
            return False
    
    def get_file_url(self, s3_key: str) -> str:
        """Get public URL for file"""
        return f"https://{self.bucket_name}.s3.{os.getenv('AWS_REGION', 'us-east-1')}.amazonaws.com/{s3_key}"

# Global instance
s3_service = S3Service()
