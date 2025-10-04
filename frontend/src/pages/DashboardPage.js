import React, { useState, useEffect } from 'react';
import { Row, Col, Card, Typography, Button, Space, message, Empty } from 'antd';
import { 
  UploadOutlined, 
  DownloadOutlined, 
  EyeOutlined,
  ClockCircleOutlined,
  CheckCircleOutlined,
  ExclamationCircleOutlined
} from '@ant-design/icons';
import { useAuth } from '../utils/AuthContext';
import { videoAPI } from '../services/api';
import VideoUploader from '../components/VideoUploader';
import JobCard from '../components/JobCard';

const { Title, Text } = Typography;

const DashboardPage = () => {
  const { user, isSubscribed } = useAuth();
  const [jobs, setJobs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    fetchJobs();
  }, []);

  const fetchJobs = async () => {
    try {
      const response = await videoAPI.getUserJobs();
      setJobs(response.data);
    } catch (error) {
      message.error('Failed to fetch jobs');
    } finally {
      setLoading(false);
    }
  };

  const handleUploadSuccess = (data) => {
    message.success('Video uploaded successfully! Processing started.');
    setUploading(false);
    fetchJobs(); // Refresh jobs list
  };

  const handleUploadError = (error) => {
    message.error('Upload failed');
    setUploading(false);
  };

  const handleDownload = async (jobId) => {
    try {
      const response = await videoAPI.downloadVideo(jobId);
      const link = document.createElement('a');
      link.href = response.data.download_url;
      link.download = `processed_video_${jobId}.mp4`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    } catch (error) {
      message.error('Download failed');
    }
  };

  const getStatusIcon = (status) => {
    switch (status) {
      case 'pending':
        return <ClockCircleOutlined className="status-pending" />;
      case 'processing':
        return <ClockCircleOutlined className="status-processing" />;
      case 'completed':
        return <CheckCircleOutlined className="status-completed" />;
      case 'failed':
        return <ExclamationCircleOutlined className="status-failed" />;
      default:
        return <ClockCircleOutlined />;
    }
  };

  const getStatusText = (status) => {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  };

  if (!isSubscribed()) {
    return (
      <div style={{ padding: '48px 24px', textAlign: 'center' }}>
        <Card style={{ maxWidth: '600px', margin: '0 auto' }}>
          <Title level={2}>Subscription Required</Title>
          <Text type="secondary" style={{ fontSize: '1.1rem', display: 'block', marginBottom: '24px' }}>
            You need an active subscription to upload and process videos.
          </Text>
          <Button type="primary" size="large" href="/pricing">
            View Pricing Plans
          </Button>
        </Card>
      </div>
    );
  }

  return (
    <div style={{ padding: '24px', maxWidth: '1200px', margin: '0 auto' }}>
      <div style={{ marginBottom: '32px' }}>
        <Title level={2}>Dashboard</Title>
        <Text type="secondary">
          Welcome back, {user?.email}! Upload videos to remove watermarks.
        </Text>
      </div>

      {/* Upload Section */}
      <Card 
        title="Upload Video" 
        style={{ marginBottom: '32px' }}
        extra={
          <Button 
            type="primary" 
            icon={<UploadOutlined />}
            onClick={() => setUploading(true)}
            disabled={uploading}
          >
            Upload Video
          </Button>
        }
      >
        <VideoUploader
          onUploadSuccess={handleUploadSuccess}
          onUploadError={handleUploadError}
        />
      </Card>

      {/* Jobs Section */}
      <Card title="Processing History">
        {loading ? (
          <div style={{ textAlign: 'center', padding: '48px' }}>
            <Text>Loading...</Text>
          </div>
        ) : jobs.length === 0 ? (
          <Empty
            description="No videos uploaded yet"
            image={Empty.PRESENTED_IMAGE_SIMPLE}
          >
            <Button type="primary" onClick={() => setUploading(true)}>
              Upload Your First Video
            </Button>
          </Empty>
        ) : (
          <Row gutter={[16, 16]}>
            {jobs.map((job) => (
              <Col xs={24} sm={12} lg={8} key={job.id}>
                <JobCard
                  job={job}
                  onDownload={handleDownload}
                  statusIcon={getStatusIcon(job.status)}
                  statusText={getStatusText(job.status)}
                />
              </Col>
            ))}
          </Row>
        )}
      </Card>
    </div>
  );
};

export default DashboardPage;
