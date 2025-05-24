# Foster Care Management System - Entity Relationship Diagram

```mermaid
erDiagram
    users ||--o{ staff : "has"
    users ||--o{ documents : "uploads"
    users ||--o{ tasks : "creates"
    users ||--o{ notes : "creates"
    users ||--o{ tasks : "assigned_to"
    users ||--o{ trainings : "verifies"
    
    children ||--o{ placementHistory : "has"
    children ||--o{ documents : "has"
    children ||--o{ notes : "has"
    children ||--o{ tasks : "has"
    
    fosterHomes ||--o{ fosterParents : "contains"
    fosterHomes ||--o{ placementHistory : "has"
    fosterHomes ||--o{ documents : "has"
    fosterHomes ||--o{ notes : "has"
    fosterHomes ||--o{ tasks : "has"
    
    fosterParents ||--o{ documents : "has"
    fosterParents ||--o{ trainings : "completes"
    fosterParents ||--o{ notes : "has"
    fosterParents ||--o{ tasks : "has"
    
    staff ||--o{ staff : "supervises"
    staff ||--o{ documents : "has"
    staff ||--o{ trainings : "completes"
    staff ||--o{ notes : "has"
    staff ||--o{ tasks : "has"
    
    users {
        int id PK
        string username UK
        string password
        string fullName
        string role
        string email
        string phone
    }
    
    children {
        int id PK
        string firstName
        string lastName
        string middleName
        string dfpsId UK
        date dateOfBirth
        string gender
        string race
        string ethnicity
        int currentPlacementId FK
        date placementDate
        int primaryCaseManagerId FK
        string medicalNeeds
        string educationalNeeds
        string behavioralNeeds
        timestamp createdAt
        timestamp updatedAt
    }
    
    fosterHomes {
        int id PK
        string homeName
        string address
        string city
        string state
        string zipCode
        string homePhone
        date licensureDate
        date licensureExpiryDate
        date homeStudyDate
        int primaryContactId FK
        int capacity
        int currentOccupancy
        timestamp createdAt
        timestamp updatedAt
    }
    
    fosterParents {
        int id PK
        string firstName
        string lastName
        string middleName
        date dateOfBirth
        string gender
        string email
        string cellPhone
        string ssn
        string relationshipStatus
        string occupation
        string employerName
        string employerPhone
        int fosterHomeId FK
        boolean primaryParent
        int trainingHours
        timestamp createdAt
        timestamp updatedAt
    }
    
    staff {
        int id PK
        int userId FK
        string title
        date hireDate
        string department
        int supervisorId FK
        date dateOfBirth
        string ssn
        string address
        string city
        string state
        string zipCode
        string cellPhone
        string emergencyContactName
        string emergencyContactPhone
        string credentialType
        string credentialNumber
        date credentialExpiryDate
        string[] certifications
        timestamp createdAt
        timestamp updatedAt
    }
    
    documents {
        int id PK
        string fileName
        string filePath
        string fileType
        int fileSize
        string documentType
        string entityType
        int entityId
        int uploadedById FK
        timestamp uploadedAt
        date expiryDate
        boolean isRequired
        string notes
    }
    
    placementHistory {
        int id PK
        int childId FK
        int fosterHomeId FK
        date placementDate
        date removalDate
        string removalReason
        string notes
        timestamp createdAt
        timestamp updatedAt
    }
    
    trainings {
        int id PK
        string title
        string description
        string provider
        date completionDate
        date expiryDate
        int hoursAwarded
        string certificateId
        string certificateUrl
        string entityType
        int entityId
        string talentLmsId
        boolean isVerified
        int verifiedById FK
        timestamp verifiedAt
        timestamp createdAt
        timestamp updatedAt
    }
    
    notes {
        int id PK
        string title
        string content
        string entityType
        int entityId
        int createdById FK
        timestamp createdAt
        timestamp updatedAt
        string noteType
        boolean isPrivate
    }
    
    tasks {
        int id PK
        string title
        string description
        date dueDate
        string priority
        string status
        string entityType
        int entityId
        int assignedToId FK
        int createdById FK
        timestamp createdAt
        timestamp updatedAt
        timestamp completedAt
        int completedById FK
    }
```

## Schema Notes

1. **Entity Types**: For entities like documents, notes, trainings, and tasks, the `entityType` field indicates which entity (child, foster parent, staff, foster home) the record is associated with, and `entityId` points to that entity's ID.

2. **User Relationships**: Users can be staff members, create tasks, upload documents, and verify trainings.

3. **Key Relationships**:
   - Children are placed in foster homes (tracked in placement history)
   - Foster parents belong to foster homes
   - Staff can supervise other staff members
   - Each entity can have documents, notes, and tasks associated with it
   - Foster parents and staff complete trainings

4. **Audit Trails**: Most tables include creation and update timestamps, as well as user IDs for who created or modified records.