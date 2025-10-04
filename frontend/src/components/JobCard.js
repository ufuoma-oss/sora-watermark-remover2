import React from 'react';
import { Card, Button, Space, Typography, Tag } from 'antd';
import { DownloadOutlined, EyeOutlined } from '@ant-design/icons';

const { Text, Title } = Typography;

const JobCard = ({ job, onDownload, statusIcon, statusText }) => {
  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'pending':
        return 'warning';
      case 'processing':
        return 'processing';
      case 'completed':
        return 'success';
      case 'failed':
        return 'error';
      default:
        return 'default';
    }
  };

  return (
    <Card
      className="job-card"
      title={
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          {statusIcon}
          <Text strong style={{ fontSize: '1rem' }}>
            {job.original_filename}
          </Text>
        </div>
      }
      extra={
        <Tag color={getStatusColor(job.status)}>
          {statusText}
        </Tag>
      }
      actions={[
        job.status === 'completed' && (
          <Button
            type="primary"
            icon={<DownloadOutlined />}
            onClick={() => onDownload(job.id)}
            size="small"
          >
            Download
          </Button>
        ),
        job.status === 'processing' && (
          <Button
            icon={<EyeOutlined />}
            onClick={() => {/* TODO: Show progress modal */}}
            size="small"
          >
            View Progress
          </Button>
        )
      ].filter(Boolean)}
    >
      <Space direction="vertical" style={{ width: '100%' }}>
        <div>
          <Text type="secondary" style={{ fontSize: '0.9rem' }}>
            Uploaded: {formatDate(job.created_at)}
          </Text>
        </div>
        
        {job.processing_started_at && (
          <div>
            <Text type="secondary" style={{ fontSize: '0.9rem' }}>
              Started: {formatDate(job.processing_started_at)}
            </Text>
          </div>
        )}
        
        {job.processing_completed_at && (
          <div>
            <Text type="secondary" style={{ fontSize: '0.9rem' }}>
              Completed: {formatDate(job.processing_completed_at)}
            </Text>
          </div>
        )}
        
        {job.error_message && (
          <div>
            <Text type="danger" style={{ fontSize: '0.9rem' }}>
              Error: {job.error_message}
            </Text>
          </div>
        )}
      </Space>
    </Card>
  );
};

export default JobCard;
