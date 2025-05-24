# Case Management Schema Proposal

Based on the requirements for the new Case Management module, we need to create additional database tables to support the following functions:

1. Case Intake
2. Case Dashboard/Summary
3. Case Status Tracking 
4. Case Closure

Here's a proposed schema extension to support these features:

## 1. Cases Table

```typescript
// Case Management Enums
export const caseStatusEnum = pgEnum('case_status', ['active', 'on_hold', 'closed']);
export const permanencyGoalEnum = pgEnum('permanency_goal', [
  'reunification', 
  'adoption', 
  'guardianship', 
  'relative_placement',
  'long_term_foster_care', 
  'independent_living',
  'other'
]);

// Main Cases table
export const cases = pgTable("cases", {
  id: serial("id").primaryKey(),
  caseNumber: text("case_number").notNull().unique(), // Generated case ID/number
  childId: integer("child_id").references(() => children.id).notNull(),
  caseworkerId: integer("caseworker_id").references(() => users.id).notNull(),
  supervisorId: integer("supervisor_id").references(() => users.id),
  
  // Intake information
  referralSource: text("referral_source").notNull(),
  referralDate: date("referral_date").notNull(),
  placementReason: text("placement_reason").notNull(),
  placementDate: date("placement_date").notNull(),
  
  // Status tracking
  status: caseStatusEnum("status").default('active').notNull(),
  statusReason: text("status_reason"),
  statusDate: date("status_date").defaultNow().notNull(),
  
  // Permanency planning
  permanencyGoal: permanencyGoalEnum("permanency_goal").default('reunification').notNull(),
  permanencyGoalDate: date("permanency_goal_date"), // When this goal was set
  
  // Risk assessment & initial data
  riskFactors: json("risk_factors").$type<string[]>().default([]),
  initialAssessment: text("initial_assessment"),
  
  // Important dates
  nextReviewDate: date("next_review_date"),
  nextCourtDate: date("next_court_date"),
  
  // Emergency contact
  emergencyContactName: text("emergency_contact_name"),
  emergencyContactPhone: text("emergency_contact_phone"),
  emergencyContactRelationship: text("emergency_contact_relationship"),
  
  // Case lifecycle
  openDate: date("open_date").defaultNow().notNull(),
  closeDate: date("close_date"),
  closureReason: text("closure_reason"),
  
  // Metadata
  createdById: integer("created_by_id").references(() => users.id).notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertCaseSchema = createInsertSchema(cases).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

export type Case = typeof cases.$inferSelect;
export type InsertCase = z.infer<typeof insertCaseSchema>;
```

## 2. Case Timeline Events Table

```typescript
export const caseTimelineEventTypeEnum = pgEnum('event_type', [
  'status_change',
  'placement_change', 
  'court_hearing',
  'permanency_goal_change',
  'visit',
  'assessment',
  'medical',
  'educational',
  'document_added',
  'note_added',
  'task_created',
  'task_completed',
  'other'
]);

export const caseTimelineEvents = pgTable("case_timeline_events", {
  id: serial("id").primaryKey(),
  caseId: integer("case_id").references(() => cases.id).notNull(),
  eventType: caseTimelineEventTypeEnum("event_type").notNull(),
  eventDate: date("event_date").notNull(),
  title: text("title").notNull(),
  description: text("description"),
  relatedEntityType: text("related_entity_type"), // Optional: "document", "task", "note", etc.
  relatedEntityId: integer("related_entity_id"), // Optional: ID of the related entity
  createdById: integer("created_by_id").references(() => users.id).notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertCaseTimelineEventSchema = createInsertSchema(caseTimelineEvents).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

export type CaseTimelineEvent = typeof caseTimelineEvents.$inferSelect;
export type InsertCaseTimelineEvent = z.infer<typeof insertCaseTimelineEventSchema>;
```

## 3. Case Closure Details Table
This provides more detailed information when a case is closed.

```typescript
export const caseClosures = pgTable("case_closures", {
  id: serial("id").primaryKey(),
  caseId: integer("case_id").references(() => cases.id).notNull().unique(),
  closureDate: date("closure_date").notNull(),
  closureReason: text("closure_reason").notNull(),
  permanencyOutcome: text("permanency_outcome").notNull(),
  finalPlacementType: text("final_placement_type").notNull(),
  finalPlacementAddress: text("final_placement_address").notNull(),
  finalPlacementContact: text("final_placement_contact").notNull(),
  serviceEndDate: date("service_end_date").notNull(),
  requiresFollowUp: boolean("requires_follow_up").default(false),
  followUpDate: date("follow_up_date"),
  followUpCompletedDate: date("follow_up_completed_date"),
  closureNotes: text("closure_notes"),
  documentsAttached: boolean("documents_attached").default(false),
  supervisorApprovalRequired: boolean("supervisor_approval_required").default(true),
  supervisorApprovalDate: date("supervisor_approval_date"),
  supervisorId: integer("supervisor_id").references(() => users.id),
  createdById: integer("created_by_id").references(() => users.id).notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertCaseClosureSchema = createInsertSchema(caseClosures).omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

export type CaseClosure = typeof caseClosures.$inferSelect;
export type InsertCaseClosure = z.infer<typeof insertCaseClosureSchema>;
```

## Integration with Existing Schema

This proposal integrates with the existing schema by:

1. Referencing the `children` table for child information
2. Referencing the `users` table for caseworkers and supervisors
3. Maintaining compatibility with the existing document system by using the entity type "case" in the `documents` table
4. Working with the existing `notes` and `tasks` systems in the same way

## Database Relationships

- One child can have multiple cases (though typically just one active case)
- One case can have multiple timeline events
- One case can have one closure record
- Cases can be linked to tasks, notes, and documents through the existing entity type/entity id pattern

## Implementation Plan

1. Add these schema definitions to the `shared/schema.ts` file
2. Create the necessary database migrations
3. Update the existing storage interfaces to work with these new tables
4. Implement the controller logic for the case management functions
5. Connect the frontend components to the API endpoints