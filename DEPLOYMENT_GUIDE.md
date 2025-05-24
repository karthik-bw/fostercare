# Foster Care Case Management System: Deployment Guide

This guide provides instructions for deploying the Foster Care Case Management System to production environments.

## Prerequisites

- Node.js 18+ and npm
- PostgreSQL 14+
- A production server (AWS, Digital Ocean, Heroku, etc.)
- Domain name (optional but recommended)

## Environment Setup

Before deploying, create the following environment variables:

```
# Database
DATABASE_URL=postgresql://username:password@hostname:port/database_name

# Server
PORT=5000
NODE_ENV=production

# Security
SESSION_SECRET=your-strong-session-secret
```

## Database Setup in Production

1. Create a production PostgreSQL database
2. Secure your database with strong passwords and proper network security
3. Deploy the schema using Drizzle:

```bash
NODE_ENV=production npm run db:push
```

4. Consider using a database backup strategy:

```bash
# Example backup cron job
0 2 * * * pg_dump -U username -d database_name > /path/to/backups/backup_$(date +%Y%m%d).sql
```

## Deployment Options

### Option 1: Traditional Server Deployment

1. Clone the repository on your server:
```bash
git clone https://github.com/yourusername/foster-care-management.git
cd foster-care-management
```

2. Install dependencies:
```bash
npm install --production
```

3. Build the frontend:
```bash
npm run build
```

4. Start the server:
```bash
npm start
```

5. Use a process manager like PM2 to keep the application running:
```bash
npm install -g pm2
pm2 start npm --name "foster-care-app" -- start
pm2 save
pm2 startup
```

### Option 2: Docker Deployment

The application includes Docker configuration files for containerized deployment.

1. Build the Docker image:
```bash
docker build -t foster-care-app .
```

2. Run the container:
```bash
docker run -d -p 5000:5000 --env-file .env --name foster-care-app foster-care-app
```

3. For Docker Compose deployment:
```bash
docker-compose up -d
```

### Option 3: AWS Deployment

The repository includes an AWS CloudFormation template for easy deployment to AWS.

1. Log in to AWS Management Console
2. Navigate to CloudFormation
3. Create a new stack
4. Upload the `aws-cloudformation-template.yml` file
5. Follow the prompts to configure your deployment
6. See [AWS Deployment Guide](AWS_DEPLOYMENT_GUIDE.md) for detailed instructions

## Nginx Configuration (Optional)

If using Nginx as a reverse proxy:

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## SSL Configuration (Recommended)

Use Let's Encrypt for free SSL certificates:

```bash
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

## Post-Deployment Checks

After deployment, verify:

1. The application is accessible at your domain or IP address
2. Database connections are working properly
3. All features function as expected
4. File uploads are working
5. Email notifications are sending correctly

## Monitoring and Maintenance

1. Set up application monitoring:
   - Consider using tools like New Relic, Datadog, or AWS CloudWatch

2. Database maintenance:
   - Regular backups
   - Performance monitoring
   - Periodic vacuuming

3. Security updates:
   - Regularly update dependencies
   - Apply security patches

## Troubleshooting Common Issues

### Database Connection Issues
- Verify the DATABASE_URL environment variable is correct
- Check that the database server is accessible from your application server
- Ensure the database user has the correct permissions

### Application Not Starting
- Check the application logs
- Verify Node.js version compatibility
- Ensure all environment variables are set correctly

### File Upload Issues
- Verify the uploads directory exists and has write permissions
- Check file size limits in your server configuration

## Rollback Procedure

If a deployment fails:

1. Restore the previous version:
```bash
git checkout <previous-commit-hash>
npm install
npm run build
npm start
```

2. Restore the database from backup if necessary:
```bash
psql -U username -d database_name < backup_file.sql
```

## Scaling Considerations

As your user base grows:

1. Consider horizontal scaling by adding more application servers
2. Implement a load balancer
3. Optimize database queries and add indexes
4. Consider database read replicas for heavy read operations
5. Implement caching strategies (Redis, Memcached)