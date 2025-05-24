# Foster Care Management System

A comprehensive foster care case management system that leverages intelligent technology to streamline administrative workflows and support child welfare professionals.

## Overview

This application provides a complete solution for foster care agencies to manage cases, track children and foster parents, handle document management, schedule events, track training requirements, and manage donor relationships.

## Key Features

- **Case Management**: Track cases with detailed status monitoring and compliance tracking
- **Foster Child Profiles**: Comprehensive child records with medical, educational, and placement history
- **Foster Parent Management**: Track foster parent licensing, training, and home information
- **Document Management**: Organize and categorize documents with OCR for form scanning
- **Calendar System**: Schedule and track visits, appointments, court dates, and other events
- **Training Platform**: Manage course content, enrollments, and certification requirements
- **Donor Management**: Track donations, campaigns, and donor relationships
- **Role-Based Access Control**: Secure access for case managers, administrators, foster parents, and service providers
- **Responsive Design**: Full mobile optimization for all device sizes

## Technology Stack

- **Frontend**: React with TypeScript, Tailwind CSS, shadcn/ui components
- **Backend**: Node.js with Express
- **Database**: PostgreSQL with Drizzle ORM
- **Authentication**: Custom role-based access control system
- **Document Processing**: OCR capabilities for document scanning

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- PostgreSQL 14+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/foster-care-management.git
cd foster-care-management
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
Create a `.env` file in the root directory with:
```
DATABASE_URL=postgresql://username:password@hostname:port/database_name
```

4. Set up the database:
See [Database Setup Documentation](DATABASE_SETUP.md) for detailed instructions.

5. Start the development server:
```bash
npm run dev
```

The application will be available at `http://localhost:5000`.

## Application Structure

- `/client`: Frontend React application
- `/server`: Backend Express API
- `/shared`: Shared types and database schema
- `/scripts`: Utility scripts for database management
- `/uploads`: Document storage directory

## Role-Based Access

The system supports four primary user roles:

1. **Case Manager**: Manages cases, foster children, and foster parents
2. **System Administrator**: Full system access, including user management
3. **Foster Parent**: Limited access to their own information and children in their care
4. **Service Provider**: Access to assigned cases and service documentation

## Documentation

- [Database Setup](DATABASE_SETUP.md): Database schema and setup instructions
- [AWS Deployment Guide](AWS_DEPLOYMENT_GUIDE.md): Instructions for deploying to AWS

## Development Workflow

1. Use `npm run dev` to start the development server
2. Use `npm run db:push` to update the database schema
3. Use `npm run db:seed` to populate the database with sample data

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Developed to support the critical work of foster care agencies
- Special thanks to all contributors and stakeholders who provided domain expertise
