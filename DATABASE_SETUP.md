# Foster Care Case Management System: Database Setup

This document outlines the database architecture, schema, and setup instructions for the Foster Care Case Management System.

## Database Architecture

The system uses PostgreSQL with Drizzle ORM to manage the database schema and operations. The database structure is designed to support:

- Case management tracking
- Foster children and parents information
- Document management with categorization
- Training and certification tracking
- Calendar and event scheduling
- Task management and assignments
- Donor and fundraising management

## Schema Overview

All database schema definitions are located in `shared/schema.ts`. The schema uses Drizzle ORM's declarative syntax to define tables, relationships, and constraints.

### Core Tables

1. **Users**: Staff members, administrators, and system users
2. **Children**: Foster children records with detailed profile information
3. **FosterParents**: Foster parent records with licensing and background check information
4. **FosterHomes**: Properties licensed for foster care
5. **Documents**: Document storage with metadata and categorization
6. **Cases**: Case management records with status tracking
7. **Events**: Calendar events with participant tracking
8. **Tasks**: Assignments and to-do items for staff
9. **Trainings**: Required and optional training courses
10. **Enrollments**: User enrollment in training courses
11. **Donors**: Donor records and contact information
12. **Donations**: Individual donation records with amount and purpose
13. **Campaigns**: Fundraising campaign records

### Key Relationships

- Children can be placed in foster homes (placement history)
- Foster parents are associated with foster homes
- Cases are linked to children
- Documents are categorized and linked to entities (children, foster parents, etc.)
- Events have participants from various entity types
- Tasks are assigned to staff and linked to entities

## Database Setup Instructions

### Prerequisites

- PostgreSQL 14+ installed
- Node.js 18+ and npm

### Environment Configuration

Create a `.env` file in the root directory with the following database connection details:

```
DATABASE_URL=postgresql://username:password@hostname:port/database_name
```

Replace the placeholders with your actual PostgreSQL credentials.

### Database Creation

1. Create a new PostgreSQL database:

```sql
CREATE DATABASE foster_care_management;
```

2. Create a dedicated database user (optional but recommended):

```sql
CREATE USER foster_app WITH ENCRYPTED PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE foster_care_management TO foster_app;
```

### Schema Migration

The project uses Drizzle for schema management. To set up the database schema:

1. Install dependencies:

```bash
npm install
```

2. Push the schema to the database:

```bash
npm run db:push
```

This command uses the schema defined in `shared/schema.ts` to create all necessary tables.

### Seeding Initial Data

The system includes seed scripts to populate the database with sample data:

```bash
npm run db:seed
```

This will create:
- Sample user accounts
- Demo foster children and parents
- Example cases and documents
- Training courses
- Calendar events
- Task assignments

## Database Maintenance

### Schema Updates

When making changes to the database schema:

1. Update the schema definitions in `shared/schema.ts`
2. Run the migration command:

```bash
npm run db:push
```

### Backup and Restore

To backup the database:

```bash
pg_dump -U username -d foster_care_management > backup_filename.sql
```

To restore from a backup:

```bash
psql -U username -d foster_care_management < backup_filename.sql
```

## Entity Relationship Diagram

The system's database schema includes the following key relationships:

```
Users
 ├── assigned Tasks
 ├── owned Documents
 ├── Training Enrollments
 └── created Events

Children
 ├── has Documents
 ├── has Cases
 ├── has Events
 └── has Placement History

FosterParents
 ├── has Documents
 ├── has FosterHomes
 ├── has Training records
 └── has Background checks

Cases
 ├── has Tasks
 ├── has Documents
 └── has Events

Events
 └── has Participants

Documents
 ├── has Categories
 └── linked to Entities

Donors
 └── has Donations

Campaigns
 └── has Donations
```

## Troubleshooting

Common database issues and solutions:

1. **Connection errors**: Verify your DATABASE_URL environment variable is correct
2. **Permission issues**: Ensure your database user has appropriate permissions
3. **Schema errors**: Check for any errors in `shared/schema.ts`

For additional support, consult the Drizzle ORM documentation or PostgreSQL documentation.