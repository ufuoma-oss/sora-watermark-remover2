import cv2
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from PIL import Image
import ffmpeg
import os
import tempfile
from typing import List, Tuple, Optional
import logging

logger = logging.getLogger(__name__)

class WatermarkDetector:
    """AI model for detecting watermarks in video frames"""
    
    def __init__(self):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model = self._load_detection_model()
        
    def _load_detection_model(self):
        """Load pre-trained watermark detection model"""
        # This would be a real model in production
        # For now, we'll use a simple CNN-based approach
        model = nn.Sequential(
            nn.Conv2d(3, 32, 3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2),
            nn.Conv2d(32, 64, 3, padding=1),
            nn.ReLU(),
            nn.MaxPool2d(2),
            nn.Conv2d(64, 128, 3, padding=1),
            nn.ReLU(),
            nn.AdaptiveAvgPool2d((1, 1)),
            nn.Flatten(),
            nn.Linear(128, 1),
            nn.Sigmoid()
        )
        model.to(self.device)
        return model
    
    def detect_watermark(self, frame: np.ndarray) -> np.ndarray:
        """Detect watermark regions in a frame"""
        # Convert to tensor
        frame_tensor = torch.from_numpy(frame).permute(2, 0, 1).float() / 255.0
        frame_tensor = frame_tensor.unsqueeze(0).to(self.device)
        
        # Simple heuristic-based detection for common watermark patterns
        # In production, this would use the trained model
        mask = self._heuristic_detection(frame)
        
        return mask
    
    def _heuristic_detection(self, frame: np.ndarray) -> np.ndarray:
        """Heuristic-based watermark detection for common patterns"""
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        mask = np.zeros(gray.shape, dtype=np.uint8)
        
        # Detect high-contrast regions (common in watermarks)
        edges = cv2.Canny(gray, 50, 150)
        
        # Look for rectangular regions in corners (typical watermark positions)
        corners = [
            (0, 0, frame.shape[1]//4, frame.shape[0]//4),  # Top-left
            (3*frame.shape[1]//4, 0, frame.shape[1], frame.shape[0]//4),  # Top-right
            (0, 3*frame.shape[0]//4, frame.shape[1]//4, frame.shape[0]),  # Bottom-left
            (3*frame.shape[1]//4, 3*frame.shape[0]//4, frame.shape[1], frame.shape[0])  # Bottom-right
        ]
        
        for x1, y1, x2, y2 in corners:
            corner_edges = edges[y1:y2, x1:x2]
            if np.sum(corner_edges) > 100:  # Threshold for watermark presence
                mask[y1:y2, x1:x2] = 255
        
        return mask

class WatermarkInpainter:
    """AI model for inpainting watermark regions"""
    
    def __init__(self):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model = self._load_inpainting_model()
        
    def _load_inpainting_model(self):
        """Load pre-trained inpainting model"""
        # This would be a real inpainting model in production
        # For now, we'll use a simple U-Net-like architecture
        class SimpleUNet(nn.Module):
            def __init__(self):
                super().__init__()
                self.encoder = nn.Sequential(
                    nn.Conv2d(4, 64, 3, padding=1),  # 3 RGB + 1 mask
                    nn.ReLU(),
                    nn.Conv2d(64, 64, 3, padding=1),
                    nn.ReLU(),
                    nn.MaxPool2d(2),
                    nn.Conv2d(64, 128, 3, padding=1),
                    nn.ReLU(),
                    nn.Conv2d(128, 128, 3, padding=1),
                    nn.ReLU(),
                )
                self.decoder = nn.Sequential(
                    nn.ConvTranspose2d(128, 64, 2, stride=2),
                    nn.Conv2d(64, 64, 3, padding=1),
                    nn.ReLU(),
                    nn.Conv2d(64, 3, 3, padding=1),
                    nn.Sigmoid()
                )
            
            def forward(self, x):
                encoded = self.encoder(x)
                decoded = self.decoder(encoded)
                return decoded
        
        model = SimpleUNet()
        model.to(self.device)
        return model
    
    def inpaint_frame(self, frame: np.ndarray, mask: np.ndarray) -> np.ndarray:
        """Inpaint watermark regions in a frame"""
        # Prepare input
        frame_tensor = torch.from_numpy(frame).permute(2, 0, 1).float() / 255.0
        mask_tensor = torch.from_numpy(mask).float() / 255.0
        
        # Combine frame and mask
        input_tensor = torch.cat([frame_tensor, mask_tensor.unsqueeze(0)], dim=0)
        input_tensor = input_tensor.unsqueeze(0).to(self.device)
        
        # Inpaint
        with torch.no_grad():
            inpainted = self.model(input_tensor)
            inpainted = inpainted.squeeze(0).permute(1, 2, 0).cpu().numpy()
            inpainted = (inpainted * 255).astype(np.uint8)
        
        # Apply mask to blend result
        mask_3d = np.stack([mask, mask, mask], axis=2) / 255.0
        result = frame * (1 - mask_3d) + inpainted * mask_3d
        
        return result.astype(np.uint8)

class WatermarkRemover:
    """Main class for removing watermarks from videos"""
    
    def __init__(self):
        self.detector = WatermarkDetector()
        self.inpainter = WatermarkInpainter()
        
    def remove_watermark_from_video(self, input_path: str, output_path: str) -> bool:
        """Remove watermarks from a video file"""
        try:
            # Extract frames
            frames = self._extract_frames(input_path)
            if not frames:
                logger.error("Failed to extract frames from video")
                return False
            
            # Process frames
            processed_frames = []
            for i, frame in enumerate(frames):
                logger.info(f"Processing frame {i+1}/{len(frames)}")
                
                # Detect watermark
                mask = self.detector.detect_watermark(frame)
                
                # Inpaint if watermark detected
                if np.any(mask):
                    processed_frame = self.inpainter.inpaint_frame(frame, mask)
                else:
                    processed_frame = frame
                
                processed_frames.append(processed_frame)
            
            # Reassemble video
            success = self._reassemble_video(processed_frames, input_path, output_path)
            return success
            
        except Exception as e:
            logger.error(f"Error processing video: {str(e)}")
            return False
    
    def _extract_frames(self, video_path: str) -> List[np.ndarray]:
        """Extract frames from video using OpenCV"""
        cap = cv2.VideoCapture(video_path)
        frames = []
        
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            frames.append(frame)
        
        cap.release()
        return frames
    
    def _reassemble_video(self, frames: List[np.ndarray], original_path: str, output_path: str) -> bool:
        """Reassemble processed frames into video"""
        try:
            # Get video properties from original
            cap = cv2.VideoCapture(original_path)
            fps = int(cap.get(cv2.CAP_PROP_FPS))
            width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            cap.release()
            
            # Write video
            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
            out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
            
            for frame in frames:
                out.write(frame)
            
            out.release()
            
            # Copy audio from original video
            self._copy_audio(original_path, output_path)
            
            return True
            
        except Exception as e:
            logger.error(f"Error reassembling video: {str(e)}")
            return False
    
    def _copy_audio(self, input_path: str, output_path: str):
        """Copy audio from input video to output video using ffmpeg"""
        try:
            # Create temporary file for video with audio
            temp_path = output_path.replace('.mp4', '_with_audio.mp4')
            
            # Use ffmpeg to combine video and audio
            (
                ffmpeg
                .input(output_path)
                .input(input_path)
                .output(temp_path, vcodec='copy', acodec='copy')
                .overwrite_output()
                .run(quiet=True)
            )
            
            # Replace original with audio version
            os.replace(temp_path, output_path)
            
        except Exception as e:
            logger.warning(f"Could not copy audio: {str(e)}")

# Global instance
watermark_remover = WatermarkRemover()
