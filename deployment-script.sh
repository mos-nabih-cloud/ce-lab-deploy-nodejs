# Install Node.js
curl -sL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Deploy application
mkdir ~/app && cd ~/app
npm init -y
npm install express

# Create app.js
touch app.js
sudo tee app.js <<EOF
// app.js
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.json({
    message: 'Week 2 Deployment Lab',
    hostname: process.env.HOSTNAME,
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date() });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
EOF

# Install PM2
sudo npm install -g pm2

# Start with PM2
pm2 start app.js --name myapp
pm2 startup
pm2 save

# Configure Nginx
sudo yum install -y nginx
sudo tee /etc/nginx/conf.d/app.conf <<EOF
server {
    listen 80;
    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
    }
}
EOF

sudo systemctl start nginx
sudo systemctl enable nginx