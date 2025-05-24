#!/bin/bash

# Exit on any error
set -e

# Default values
STACK_NAME="foster-care-app"
ENVIRONMENT="Production"
AWS_REGION="us-east-1"

# Functions
print_usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -s, --stack-name      CloudFormation stack name (default: foster-care-app)"
  echo "  -e, --environment     Environment: Development, Staging, Production (default: Production)"
  echo "  -r, --region          AWS region (default: us-east-1)"
  echo "  -h, --help            Show this help message"
}

print_separator() {
  echo "=================================================================="
}

check_aws_cli() {
  if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it first."
    exit 1
  fi
  
  # Check AWS credentials are configured
  if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS CLI is not configured with valid credentials."
    echo "Please run 'aws configure' to set up your credentials."
    exit 1
  fi
}

check_deps() {
  echo "Checking dependencies..."
  if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it first."
    exit 1
  fi
  
  if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install it first."
    exit 1
  fi
  
  if ! command -v jq &> /dev/null; then
    echo "Warning: jq is not installed. Some output formatting will be limited."
  fi
  
  echo "All required dependencies are installed."
}

deploy_cloudformation() {
  print_separator
  echo "Deploying CloudFormation Stack: $STACK_NAME"
  print_separator
  
  # Generate a random password for the database
  DB_PASSWORD=$(openssl rand -base64 12)
  
  # Check if stack exists
  if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $AWS_REGION &> /dev/null; then
    echo "Stack already exists. Updating..."
    
    # Update the stack
    aws cloudformation update-stack \
      --stack-name $STACK_NAME \
      --template-body file://aws-cloudformation-template.yml \
      --parameters ParameterKey=EnvironmentName,ParameterValue=$ENVIRONMENT \
                   ParameterKey=DBPassword,ParameterValue=$DB_PASSWORD \
      --capabilities CAPABILITY_IAM \
      --region $AWS_REGION
      
    # Wait for the stack to update
    echo "Waiting for stack update to complete... (this may take 15-20 minutes)"
    aws cloudformation wait stack-update-complete \
      --stack-name $STACK_NAME \
      --region $AWS_REGION
  else
    echo "Creating new stack..."
    
    # Create the stack
    aws cloudformation create-stack \
      --stack-name $STACK_NAME \
      --template-body file://aws-cloudformation-template.yml \
      --parameters ParameterKey=EnvironmentName,ParameterValue=$ENVIRONMENT \
                   ParameterKey=DBPassword,ParameterValue=$DB_PASSWORD \
      --capabilities CAPABILITY_IAM \
      --region $AWS_REGION
      
    # Wait for the stack to be created
    echo "Waiting for stack creation to complete... (this may take 15-20 minutes)"
    aws cloudformation wait stack-create-complete \
      --stack-name $STACK_NAME \
      --region $AWS_REGION
  fi
  
  # Get the outputs
  OUTPUTS=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $AWS_REGION \
    --query "Stacks[0].Outputs" \
    --output json)
  
  # Save the stack outputs to a file
  echo $OUTPUTS > stack-outputs.json
  
  # Extract the repository URL
  ECR_REPO_URL=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey=="ECRRepositoryUrl") | .OutputValue')
  
  echo "Stack deployed successfully!"
  echo "ECR Repository URL: $ECR_REPO_URL"
  echo "Database password (save this securely): $DB_PASSWORD"
  echo "All outputs saved to stack-outputs.json"
  
  # Return the repository URL for the next step
  echo "$ECR_REPO_URL"
}

build_and_push_docker_image() {
  local ecr_repo_url=$1
  print_separator
  echo "Building and pushing Docker image to: $ecr_repo_url"
  print_separator
  
  # Build the Docker image
  echo "Building Docker image..."
  docker build -t foster-care-app .
  
  # Log in to ECR
  echo "Logging in to Amazon ECR..."
  aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ecr_repo_url
  
  # Tag the image
  echo "Tagging Docker image..."
  docker tag foster-care-app:latest $ecr_repo_url:latest
  
  # Push the image
  echo "Pushing image to ECR..."
  docker push $ecr_repo_url:latest
  
  echo "Docker image pushed successfully!"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -s|--stack-name)
      STACK_NAME="$2"
      shift 2
      ;;
    -e|--environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    -r|--region)
      AWS_REGION="$2"
      shift 2
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      print_usage
      exit 1
      ;;
  esac
done

# Main script
echo "=== Foster Care App AWS Deployment ==="
echo "Stack Name: $STACK_NAME"
echo "Environment: $ENVIRONMENT"
echo "AWS Region: $AWS_REGION"
print_separator

# Check dependencies
check_deps

# Deploy CloudFormation stack
ECR_REPO_URL=$(deploy_cloudformation)

# Build and push Docker image
build_and_push_docker_image $ECR_REPO_URL

print_separator
echo "Deployment complete!"
echo "To access your application, check the LoadBalancerUrl in stack-outputs.json"
print_separator