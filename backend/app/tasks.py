from celery import current_task
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.celery_app import celery_app
from app.database import SessionLocal
from app.models import Job, JobStatus
from services.watermark_remover import watermark_remover
import os
import logging

logger = logging.getLogger(__name__)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@celery_app.task(bind=True)
def process_video(self, job_id: int):
    """Process video to remove watermarks"""
    db = SessionLocal()
    try:
        # Get job from database
        job = db.query(Job).filter(Job.id == job_id).first()
        if not job:
            logger.error(f"Job {job_id} not found")
            return
        
        # Update job status to processing
        job.status = JobStatus.PROCESSING
        job.processing_started_at = db.query(func.now()).scalar()
        db.commit()
        
        # Process video
        input_path = job.original_file_path
        output_filename = f"processed_{job.original_filename}"
        output_path = os.path.join(os.path.dirname(input_path), output_filename)
        
        # Update progress
        current_task.update_state(
            state="PROGRESS",
            meta={"current": 0, "total": 100, "status": "Starting watermark removal..."}
        )
        
        # Remove watermarks
        success = watermark_remover.remove_watermark_from_video(input_path, output_path)
        
        if success:
            # Update job with success
            job.status = JobStatus.COMPLETED
            job.processed_file_path = output_path
            job.processing_completed_at = db.query(func.now()).scalar()
            db.commit()
            
            current_task.update_state(
                state="SUCCESS",
                meta={"current": 100, "total": 100, "status": "Video processed successfully"}
            )
            
            logger.info(f"Job {job_id} completed successfully")
        else:
            # Update job with failure
            job.status = JobStatus.FAILED
            job.error_message = "Watermark removal failed"
            job.processing_completed_at = db.query(func.now()).scalar()
            db.commit()
            
            current_task.update_state(
                state="FAILURE",
                meta={"current": 0, "total": 100, "status": "Watermark removal failed"}
            )
            
            logger.error(f"Job {job_id} failed")
            
    except Exception as e:
        logger.error(f"Error processing job {job_id}: {str(e)}")
        
        # Update job with error
        job.status = JobStatus.FAILED
        job.error_message = str(e)
        job.processing_completed_at = db.query(func.now()).scalar()
        db.commit()
        
        current_task.update_state(
            state="FAILURE",
            meta={"current": 0, "total": 100, "status": f"Error: {str(e)}"}
        )
        
    finally:
        db.close()
