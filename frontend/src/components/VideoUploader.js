import React, { useState, useCallback } from 'react';
import { Upload, message, Progress, Button, Typography } from 'antd';
import { InboxOutlined, UploadOutlined } from '@ant-design/icons';
import { useDropzone } from 'react-dropzone';
import { videoAPI } from '../services/api';

const { Dragger } = Upload;
const { Text } = Typography;

const VideoUploader = ({ onUploadSuccess, onUploadError }) => {
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);

  const onDrop = useCallback((acceptedFiles) => {
    if (acceptedFiles.length > 0) {
      handleUpload(acceptedFiles[0]);
    }
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'video/*': ['.mp4', '.mov', '.avi', '.mkv', '.webm']
    },
    multiple: false,
    disabled: uploading
  });

  const handleUpload = async (file) => {
    if (!file) return;

    // Validate file size (500MB limit)
    const maxSize = 500 * 1024 * 1024; // 500MB
    if (file.size > maxSize) {
      message.error('File size must be less than 500MB');
      return;
    }

    // Validate file type
    if (!file.type.startsWith('video/')) {
      message.error('Please select a video file');
      return;
    }

    setUploading(true);
    setProgress(0);

    try {
      // Simulate upload progress
      const progressInterval = setInterval(() => {
        setProgress(prev => {
          if (prev >= 90) {
            clearInterval(progressInterval);
            return prev;
          }
          return prev + Math.random() * 10;
        });
      }, 200);

      const response = await videoAPI.upload(file);
      
      clearInterval(progressInterval);
      setProgress(100);
      
      message.success('Video uploaded successfully!');
      
      if (onUploadSuccess) {
        onUploadSuccess(response.data);
      }
      
    } catch (error) {
      message.error(error.response?.data?.detail || 'Upload failed');
      
      if (onUploadError) {
        onUploadError(error);
      }
    } finally {
      setUploading(false);
      setProgress(0);
    }
  };

  const uploadProps = {
    name: 'file',
    multiple: false,
    showUploadList: false,
    beforeUpload: (file) => {
      handleUpload(file);
      return false; // Prevent default upload
    },
    accept: 'video/*'
  };

  return (
    <div>
      <Dragger
        {...getRootProps()}
        {...uploadProps}
        className={`upload-area ${isDragActive ? 'dragover' : ''}`}
        disabled={uploading}
      >
        <input {...getInputProps()} />
        <p className="ant-upload-drag-icon">
          <InboxOutlined style={{ fontSize: '3rem', color: '#1890ff' }} />
        </p>
        <p className="ant-upload-text" style={{ fontSize: '1.2rem', marginBottom: '8px' }}>
          {isDragActive ? 'Drop your video here' : 'Click or drag video to upload'}
        </p>
        <p className="ant-upload-hint" style={{ fontSize: '1rem' }}>
          Support for MP4, MOV, AVI, MKV, and WebM formats. Max file size: 500MB
        </p>
        {uploading && (
          <div style={{ marginTop: '16px' }}>
            <Progress 
              percent={Math.round(progress)} 
              status={progress === 100 ? 'success' : 'active'}
            />
            <Text type="secondary" style={{ fontSize: '0.9rem' }}>
              {progress === 100 ? 'Processing...' : 'Uploading...'}
            </Text>
          </div>
        )}
      </Dragger>
    </div>
  );
};

export default VideoUploader;
