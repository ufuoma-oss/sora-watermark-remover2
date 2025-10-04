import React from 'react';
import { Row, Col, Typography, Button, Card, Space } from 'antd';
import { 
  PlayCircleOutlined, 
  ThunderboltOutlined, 
  SafetyOutlined,
  CloudUploadOutlined,
  CheckCircleOutlined
} from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../utils/AuthContext';
import VideoUploader from '../components/VideoUploader';

const { Title, Paragraph } = Typography;

const HomePage = () => {
  const navigate = useNavigate();
  const { isAuthenticated, isSubscribed } = useAuth();

  const features = [
    {
      icon: <ThunderboltOutlined className="feature-icon" />,
      title: 'AI-Powered Removal',
      description: 'Advanced machine learning algorithms detect and remove watermarks with 99%+ accuracy'
    },
    {
      icon: <SafetyOutlined className="feature-icon" />,
      title: 'Secure Processing',
      description: 'Your videos are processed securely and automatically deleted after 7 days'
    },
    {
      icon: <CloudUploadOutlined className="feature-icon" />,
      title: 'Cloud-Based',
      description: 'No software installation required. Process videos directly in your browser'
    },
    {
      icon: <CheckCircleOutlined className="feature-icon" />,
      title: 'High Quality',
      description: 'Maintains original video quality with no compression artifacts'
    }
  ];

  return (
    <div>
      {/* Hero Section */}
      <div className="hero-section">
        <div style={{ maxWidth: '1200px', margin: '0 auto', padding: '0 24px' }}>
          <Title className="hero-title">
            Remove Watermarks with AI Precision
          </Title>
          <Paragraph className="hero-subtitle">
            Eliminate TikTok, Sora, and other watermarks from your videos with our 
            state-of-the-art AI technology. Get clean, professional results in seconds.
          </Paragraph>
          
          {isAuthenticated() ? (
            <Space size="large">
              <Button 
                type="primary" 
                size="large"
                onClick={() => navigate('/dashboard')}
              >
                Go to Dashboard
              </Button>
              {!isSubscribed() && (
                <Button 
                  size="large"
                  onClick={() => navigate('/pricing')}
                >
                  View Pricing
                </Button>
              )}
            </Space>
          ) : (
            <Space size="large">
              <Button 
                type="primary" 
                size="large"
                onClick={() => navigate('/register')}
              >
                Get Started Free
              </Button>
              <Button 
                size="large"
                onClick={() => navigate('/pricing')}
              >
                View Pricing
              </Button>
            </Space>
          )}
        </div>
      </div>

      {/* Features Section */}
      <div style={{ padding: '80px 24px', background: 'white' }}>
        <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
          <Title level={2} style={{ textAlign: 'center', marginBottom: '48px' }}>
            Why Choose Our Watermark Remover?
          </Title>
          <Row gutter={[24, 24]}>
            {features.map((feature, index) => (
              <Col xs={24} sm={12} lg={6} key={index}>
                <Card className="feature-card">
                  {feature.icon}
                  <Title level={4}>{feature.title}</Title>
                  <Paragraph>{feature.description}</Paragraph>
                </Card>
              </Col>
            ))}
          </Row>
        </div>
      </div>

      {/* How It Works Section */}
      <div style={{ padding: '80px 24px', background: '#f5f5f5' }}>
        <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
          <Title level={2} style={{ textAlign: 'center', marginBottom: '48px' }}>
            How It Works
          </Title>
          <Row gutter={[24, 24]} align="middle">
            <Col xs={24} md={12}>
              <Title level={3}>1. Upload Your Video</Title>
              <Paragraph>
                Simply drag and drop your video file or click to browse. 
                We support MP4, MOV, AVI, and other popular formats.
              </Paragraph>
            </Col>
            <Col xs={24} md={12}>
              <div style={{ textAlign: 'center' }}>
                <CloudUploadOutlined style={{ fontSize: '4rem', color: '#1890ff' }} />
              </div>
            </Col>
          </Row>
          
          <Row gutter={[24, 24]} align="middle" style={{ marginTop: '48px' }}>
            <Col xs={24} md={12} order={{ xs: 2, md: 1 }}>
              <div style={{ textAlign: 'center' }}>
                <ThunderboltOutlined style={{ fontSize: '4rem', color: '#1890ff' }} />
              </div>
            </Col>
            <Col xs={24} md={12} order={{ xs: 1, md: 2 }}>
              <Title level={3}>2. AI Processing</Title>
              <Paragraph>
                Our advanced AI detects watermarks frame by frame and 
                intelligently reconstructs the background for seamless removal.
              </Paragraph>
            </Col>
          </Row>
          
          <Row gutter={[24, 24]} align="middle" style={{ marginTop: '48px' }}>
            <Col xs={24} md={12}>
              <Title level={3}>3. Download Clean Video</Title>
              <Paragraph>
                Get your watermark-free video in high quality. 
                Download instantly or save to your account for later access.
              </Paragraph>
            </Col>
            <Col xs={24} md={12}>
              <div style={{ textAlign: 'center' }}>
                <CheckCircleOutlined style={{ fontSize: '4rem', color: '#52c41a' }} />
              </div>
            </Col>
          </Row>
        </div>
      </div>

      {/* CTA Section */}
      <div style={{ 
        padding: '80px 24px', 
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        color: 'white',
        textAlign: 'center'
      }}>
        <div style={{ maxWidth: '800px', margin: '0 auto' }}>
          <Title level={2} style={{ color: 'white', marginBottom: '24px' }}>
            Ready to Remove Watermarks?
          </Title>
          <Paragraph style={{ fontSize: '1.2rem', marginBottom: '32px', color: 'rgba(255,255,255,0.9)' }}>
            Join thousands of content creators who trust our AI-powered watermark removal technology.
          </Paragraph>
          <Space size="large">
            <Button 
              type="primary" 
              size="large"
              onClick={() => navigate(isAuthenticated() ? '/dashboard' : '/register')}
              style={{ 
                background: 'white', 
                color: '#1890ff',
                border: 'none',
                height: '48px',
                padding: '0 32px',
                fontSize: '16px',
                fontWeight: '600'
              }}
            >
              {isAuthenticated() ? 'Go to Dashboard' : 'Start Free Trial'}
            </Button>
            <Button 
              size="large"
              onClick={() => navigate('/pricing')}
              style={{ 
                color: 'white', 
                borderColor: 'white',
                height: '48px',
                padding: '0 32px',
                fontSize: '16px'
              }}
            >
              View Pricing
            </Button>
          </Space>
        </div>
      </div>
    </div>
  );
};

export default HomePage;
