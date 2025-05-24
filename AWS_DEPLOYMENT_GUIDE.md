# AWS Deployment Guide for Foster Care Case Management System

This guide provides comprehensive steps to deploy the application to AWS, focusing on a production-ready setup.

## Prerequisites

1. AWS account with appropriate permissions
2. AWS CLI installed and configured
3. Docker (optional for containerization)
4. Git to clone the repository

## Step 1: Database Setup (AWS RDS/Aurora)

1. **Create an RDS PostgreSQL instance**:
   - Go to AWS Console > RDS > Create database
   - Choose PostgreSQL and select an appropriate instance size (e.g., t3.medium for production)
   - Configure a secure master username and password
   - Make note of the database endpoint, port, username, password, and database name

2. **Configure security group**:
   - Create or modify the security group to allow traffic from your application servers
   - For development, you might temporarily allow connections from your IP

3. **Initialize the database**:
   ```bash
   # Once you have database credentials, run this from your local environment
   DATABASE_URL=postgres://username:password@db-endpoint:5432/database-name npm run db:push
   ```

## Step 2: Build the Application for Production

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Create production build**:
   ```bash
   # Install dependencies
   npm install

   # Build the client
   npm run build

   # Make a zip file for deployment
   zip -r deploy.zip dist/ package.json package-lock.json
   ```

## Step 3: Deploy to AWS Elastic Beanstalk

1. **Create Elastic Beanstalk Application**:
   - Go to AWS Console > Elastic Beanstalk > Create application
   - Choose Node.js platform
   - Upload your zip file (deploy.zip)
   - Configure environment:
     - Set NODE_ENV=production
     - Add DATABASE_URL environment variable

2. **Configure environment variables**:
   In the Elastic Beanstalk console, go to Configuration > Software > Environment properties and add:
   - `NODE_ENV` = `production`
   - `DATABASE_URL` = `postgres://username:password@db-endpoint:5432/database-name`
   - Any other required environment variables (e.g., API keys)

3. **Configure scaling**:
   - Go to Configuration > Capacity
   - Set min/max instance count based on your expected traffic
   - Choose appropriate instance type

## Step 4: Set Up AWS Route 53 (Optional)

1. **Register a domain or use existing domain**
2. **Create a DNS record pointing to your Elastic Beanstalk URL**
3. **Set up SSL certificate with AWS Certificate Manager**

## Step 5: Set Up AWS CloudFront (Optional)

1. **Create a CloudFront distribution**:
   - Origin: Your Elastic Beanstalk URL
   - Cache behaviors: Customize based on your needs
   - SSL: Use your ACM certificate

## Step 6: Monitoring and Maintenance

1. **Set up CloudWatch alarms**:
   - Monitor CPU, memory, disk usage
   - Set up notifications for critical events

2. **Set up database backups**:
   - Configure automated RDS snapshots

3. **Implement a CI/CD pipeline**:
   - Use AWS CodePipeline or GitHub Actions
   - Automate testing and deployment

## Alternative: Deploy with AWS ECS/Fargate

If you prefer containerized deployment, you can use ECS/Fargate:

1. **Create a Dockerfile**:
   ```Dockerfile
   FROM node:18-alpine
   WORKDIR /app
   COPY package*.json ./
   RUN npm ci --only=production
   COPY dist/ ./dist/
   EXPOSE 5000
   CMD ["node", "dist/index.js"]
   ```

2. **Build and push Docker image**:
   ```bash
   docker build -t foster-care-app .
   aws ecr create-repository --repository-name foster-care-app
   aws ecr get-login-password | docker login --username AWS --password-stdin <your-account>.dkr.ecr.<region>.amazonaws.com
   docker tag foster-care-app:latest <your-account>.dkr.ecr.<region>.amazonaws.com/foster-care-app:latest
   docker push <your-account>.dkr.ecr.<region>.amazonaws.com/foster-care-app:latest
   ```

3. **Create ECS cluster, task definition, and service**:
   - Use the AWS console or CloudFormation templates
   - Configure appropriate CPU/memory, environment variables, etc.

## Security Considerations

1. **Database security**:
   - Use subnets and security groups to limit access
   - Enable encryption at rest
   - Use strong passwords stored in AWS Secrets Manager

2. **Application security**:
   - Implement proper user authentication
   - Use HTTPS only
   - Regularly update dependencies

3. **Compliance**:
   - Ensure your AWS setup complies with any regulatory requirements (HIPAA, etc.)
   - Set up appropriate backup and disaster recovery procedures

## Cost Management

1. **Estimate costs**:
   - RDS instance
   - Elastic Beanstalk/ECS
   - Data transfer
   - CloudFront (if used)

2. **Use AWS Cost Explorer**:
   - Set up budgets and alerts
   - Monitor actual costs vs. budget

3. **Consider reserved instances**:
   - If you plan long-term usage, consider reserved instances for cost savings

## Deployment Script Example

Here's a sample deployment script you can use as a reference:

```bash
#!/bin/bash

# Build the application
echo "Building application..."
npm run build

# Create deployment package
echo "Creating deployment package..."
zip -r deploy.zip dist/ package.json package-lock.json

# Deploy to Elastic Beanstalk
echo "Deploying to Elastic Beanstalk..."
aws elasticbeanstalk create-application-version \
  --application-name "FosterCareApp" \
  --version-label "v-$(date +%Y%m%d-%H%M%S)" \
  --source-bundle S3Bucket="your-deployment-bucket",S3Key="deploy.zip"

aws elasticbeanstalk update-environment \
  --environment-name "FosterCareApp-env" \
  --version-label "v-$(date +%Y%m%d-%H%M%S)"

echo "Deployment complete!"
```

## Troubleshooting

1. **Check Elastic Beanstalk logs**:
   - Go to Elastic Beanstalk console > Logs
   - Check application logs for errors

2. **Database connectivity issues**:
   - Verify security group settings
   - Check database credentials
   - Ensure the database is in the same region as your application

3. **Performance issues**:
   - Check instance size
   - Monitor CPU and memory usage
   - Consider adding a caching layer (e.g., Redis) for frequently accessed data