---
model: inherit
thinking: true
---

# Ignixxion Migration Execution Workflow v2.0
**Enhanced with automated gates, progress tracking, error recovery, and priority-based ordering**
**NOTE: PHASE 0 TO 2 ARE ALREADY COMPLETED. START FROM PHASE 3.**

## Preconditions
- artifacts.json exists at IgnixxionNestAPI/migration_docs/artifacts.json
- FUNCTION_MAPPING.md, PHASE_2_BRIEFING.md, PARITY_REPORT.md, AUTH_GAPS.md, QUICK_REFERENCE.md, swagger-coverage-report.md exist in IgnixxionNestAPI/migration_docs
- progress-tracker.json will be created in Phase 0
- Git working directory is clean

## Sub-Agent Handoff Protocol
- Use the correct sub-agent for high cognition tasks only: strategy, planning, review, audit
- Invoke with watch enabled to stream actions and capture transcripts
- **Retry Logic:** All agent calls retry 3x with 30s backoff on failure
- **Validation:** All agent outputs validated before acceptance
- Prompt shape:
  ```
  Role: [Specific Role Title]
  Objective: [One sentence goal]
  Inputs:
    - artifacts.json
    - PHASE_2_BRIEFING.md
    - PARITY_REPORT.md
    - FUNCTION_MAPPING.md
    - AUTH_GAPS.md
    - QUICK_REFERENCE.md
    - swagger-coverage-report.md
  Hard Rules:
    - No endpoint renames without change record
    - Preserve on-the-wire names from FUNCTION_MAPPING.md
    - No secrets in output
    - Never write code to main
    - Multi-tenant isolation (companyId) enforced
  Success Criteria:
    - [Specific measurable outcomes]
  Testing Requirements:
    - [Specific test types and coverage]
  Required Outputs:
    - [Named files under migration_docs/agents]
  ```
  Output logs to: migration_docs/agents/logs/<phase>-<step>.log

## Abort Conditions (CRITICAL - STOP IMMEDIATELY)
- Agent proposes renaming endpoints listed in FUNCTION_MAPPING.md
- Agent suggests bypassing auth or tenant isolation in AUTH_GAPS.md
- Agent recommends exposing PostgREST directly to clients
- Agent proposes changes to prisma schema without supervisor approval
- Agent proposes to disable tests or make tests easier to pass
- Any security vulnerability introduced (detected by auth-security)
- Test coverage drops below 80%

## Artifact Locations
- All agent outputs: IgnixxionNestAPI/migration_docs/agents/
- Logs: migration_docs/agents/logs/
- Progress tracker: migration_docs/progress-tracker.json
- Phase checkpoints: Git tags (phase-X-complete)

## Key Files (ALWAYS USE AS INPUTS)
- migration_docs/artifacts.json (93 functions inventory)
- migration_docs/PHASE_2_BRIEFING.md (5% complete, blockers, timeline)
- migration_docs/PARITY_REPORT.md (gap analysis, validation queries)
- migration_docs/FUNCTION_MAPPING.md (Firebase → NestJS mapping)
- migration_docs/AUTH_GAPS.md (10 critical security issues)
- migration_docs/QUICK_REFERENCE.md (priority matrix, anti-patterns)
- migration_docs/swagger-coverage-report.md (API documentation status)

---

# EXECUTION PHASES (Priority-Ordered per PHASE_2_BRIEFING.md & QUICK_REFERENCE.md)

## Phase 0: Discovery & Planning

### 0.0 Repository Inventory Baseline
Use Task tool with subagent_type="repo-inventory"
Prompt:
"
Role: Code Analyst
Objective: Build canonical inventory of both repositories as migration baseline
Inputs:
  - Ignixxion.DM.API/functions (Firebase codebase)
  - IgnixxionNestAPI/src (NestJS codebase)
  - migration_docs/artifacts.json (existing inventory)
  - migration_docs/QUICK_REFERENCE.md (priority guidance)
Tool Usage:
  1. Glob Ignixxion.DM.API/functions/**/*.{js,ts}
  2. Grep pattern='exports\\.' in functions/index.js (find all exports)
  3. Glob IgnixxionNestAPI/src/**/*.{controller,service,module}.ts
  4. Read prisma/schema.prisma (extract models and relationships)
  5. Grep pattern='require.*httphelper' (find Pismo dependencies)
Success Criteria:
  - All 93 Firebase functions cataloged with paths and types
  - All helper module dependencies mapped
  - All NestJS modules enumerated with controllers/services
  - Prisma schema models documented with fields and indexes
Hard Rules:
  - Absolute paths only (no relative paths)
  - Include trigger types (onCall, onRequest, onSchedule, Firestore)
  - Cross-reference Firebase → NestJS existing mappings
Outputs:
  - migration_docs/inventory.json (complete inventory with dependencies)
  - migration_docs/inventory-delta.md (what's missing in NestJS)
  - migration_docs/dependency-graph.md (helper usage matrix)
"

### 0.1 Initialize Progress Tracker
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Role: Migration Coordinator
Objective: Initialize progress tracking system for entire migration
Inputs:
  - migration_docs/artifacts.json
  - migration_docs/inventory.json
  - migration_docs/PHASE_2_BRIEFING.md
Tool Usage:
  1. Read artifacts.json to get all 93 functions
  2. Write migration_docs/progress-tracker.json with structure:
     {
       'version': '2.0',
       'totalFunctions': 93,
       'completedFunctions': 1,
       'completionPercentage': 1.08,
       'phases': {
         'phase_0': {'status': 'in_progress', 'startedAt': '[ISO timestamp]'},
         'phase_1': {'status': 'pending'},
         'phase_2': {'status': 'pending'},
         ...
       },
       'domains': {
         'pismo': {'total': 44, 'completed': 0, 'priority': 'CRITICAL'},
         'companies': {'total': 5, 'completed': 0, 'priority': 'HIGH'},
         ...
       },
       'blockers': []
     }
  3. Write migration_docs/PROGRESS.md (human-readable dashboard)
Success Criteria:
  - progress-tracker.json created and valid JSON
  - All 93 functions represented
  - Domain priorities match QUICK_REFERENCE.md
Outputs:
  - migration_docs/progress-tracker.json
  - migration_docs/PROGRESS.md
"

### 0.2 Build Priority-Ordered Work Queue
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Role: Sprint Planner
Objective: Build work queue ordered by CRITICAL → HIGH → MEDIUM → LOW priority
Inputs:
  - migration_docs/artifacts.json
  - migration_docs/PHASE_2_BRIEFING.md (BLOCKER-1: Pismo Integration first)
  - migration_docs/QUICK_REFERENCE.md (priority matrix)
  - migration_docs/FUNCTION_MAPPING.md
  - migration_docs/inventory.json
Priority Order (per QUICK_REFERENCE.md):
  1. CRITICAL: Pismo webhooks (handlePismoEvent, handlePismoEventProd)
  2. CRITICAL: Pismo HTTP client (httphelper.js → PismoService)
  3. HIGH: Card operations (createCardPismo, updateCardStatusPismo, etc.)
  4. HIGH: Authorization sessions (OTP flow)
  5. HIGH: User management API
  6. MEDIUM: Account/Customer operations
  7. MEDIUM: Flex controls
  8. LOW: Email, Stripe, OCR
Tool Usage:
  1. Read QUICK_REFERENCE.md sections: 'Priority Matrix' and 'Migration Blockers'
  2. Group functions by domain and dependency
  3. For each domain, determine feature branch name
  4. Identify blocking dependencies (e.g., Pismo integration blocks card ops)
Success Criteria:
  - Pismo integration is first work item
  - Dependencies clearly marked
  - Each work item has: domain, priority, function count, branch name, dependencies
Hard Rules:
  - Pismo webhooks and HTTP client MUST be work items #1 and #2
  - No work item depends on itself
  - Branch names: feature/pismo-webhooks, feature/pismo-client, feature/cards, etc.
Outputs:
  - migration_docs/work-queue.md (ordered list with dependencies)
  - migration_docs/dependency-graph.md (visual dependency tree)
"

### 0.3 Synthesize Migration Strategy
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Role: Principal Architect
Objective: Synthesize cross-domain Phase 2 strategy and risk mitigation plan
Inputs:
  - migration_docs/PHASE_2_BRIEFING.md (5 critical blockers)
  - migration_docs/PARITY_REPORT.md (parity gaps)
  - migration_docs/FUNCTION_MAPPING.md (93 functions)
  - migration_docs/artifacts.json
  - migration_docs/work-queue.md (execution order)
Strategy Focus:
  - Address BLOCKER-1 (Pismo Integration) first - 4-5 weeks
  - Dual-write pattern for data migration
  - Staged rollout plan (0.1% → 5% → 25% → 50% → 100%)
Hard Rules:
  - Do not change endpoint names (preserve wire contracts)
  - Keep Pismo as the first critical path
  - Firebase Auth remains (DO NOT migrate away)
  - Multi-tenant isolation enforced everywhere
Success Criteria:
  - Strategy addresses all 5 blockers from PHASE_2_BRIEFING.md
  - Risk mitigation for each blocker
  - Timeline aligned with 20-week plan
Outputs:
  - migration_docs/agents/strategy.md (comprehensive strategy)
  - migration_docs/agents/adr-000-high-level-approach.md (architecture decision)
  - migration_docs/agents/risk-mitigation.md (blocker resolution plan)
"

### 0.99 Phase 0 Checkpoint
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Update migration_docs/progress-tracker.json:
  - Set phase_0.status = 'complete'
  - Set phase_0.completedAt = '[current ISO timestamp]'
  - Set phase_1.status = 'pending'
Commit changes:
  - git add migration_docs/
  - git commit -m 'chore: complete Phase 0 - discovery and planning'
  - git tag phase-0-complete
Generate summary:
  - Read progress-tracker.json
  - Write migration_docs/PROGRESS.md with updated dashboard
Output: migration_docs/agents/phase-0-completion-report.md
"

---

## Phase 1: Pismo Integration Foundation (CRITICAL BLOCKER-1)
**Priority:** CRITICAL (Blocks all payment features)
**Effort:** 4-5 weeks
**Functions:** httphelper.js, Pismo webhooks (2 functions)

### 1.0 Pismo Integration Design
Use Task tool with subagent_type="api-architect"
Prompt:
"
Role: Integration Architect
Objective: Design PismoService with mTLS client, JWT auth, circuit breaker, and webhook handling
Inputs:
  - Ignixxion.DM.API/functions/httphelper.js (275 lines, mTLS + JWT reference)
  - Ignixxion.DM.API/functions/pismo/events.js (webhook handlers)
  - migration_docs/QUICK_REFERENCE.md (complexity ratings)
  - migration_docs/AUTH_GAPS.md (AUTH-029: webhook signature verification)
Design Requirements:
  1. PismoService class structure:
     - JWT token generation and caching (58-minute TTL)
     - mTLS certificate loading from Secret Manager
     - Axios HTTP client with interceptors
     - Circuit breaker pattern (fail after 3 errors, reset after 30s)
     - Retry logic (3 retries with exponential backoff)
  2. Webhook handler:
     - JWT signature verification (AUTH-029 fix)
     - Body hash validation
     - Idempotent event processing
     - Timestamp validation (5-minute window)
     - Event queue with Bull
  3. Dual-write pattern:
     - Write to PostgreSQL (source of truth)
     - Write to Firestore (backward compatibility)
     - Retry queue for failed Firestore writes
Tool Usage:
  1. Read httphelper.js (understand mTLS and JWT logic)
  2. Read pismo/events.js (understand webhook structure)
  3. Grep pattern='mTLS|certificate|JWT' in httphelper.js
  4. Write migration_docs/agents/pismo-integration-design.md
Success Criteria:
  - Complete class diagram for PismoService
  - mTLS certificate loading strategy defined
  - JWT token cache with TTL specified
  - Circuit breaker thresholds defined
  - Webhook signature verification algorithm specified
  - Dual-write failure handling defined
Hard Rules:
  - MUST verify webhook signatures (fixes AUTH-029)
  - MUST use circuit breaker (no direct failures to user)
  - MUST cache JWT tokens (reduce Pismo API calls by 95%)
  - MUST implement idempotency for webhooks
Outputs:
  - migration_docs/agents/pismo-integration-design.md
  - migration_docs/agents/pismo-service-class-diagram.md
  - migration_docs/agents/webhook-flow-diagram.md
"

### 1.1 Implement PismoService HTTP Client
Use Task tool with subagent_type="api-architect"
Prompt:
"
Role: Backend Engineer
Objective: Implement PismoService with full mTLS, JWT, and circuit breaker functionality
Inputs:
  - migration_docs/agents/pismo-integration-design.md
  - Ignixxion.DM.API/functions/httphelper.js (reference implementation)
  - migration_docs/AUTH_GAPS.md
Implementation:
  1. Create src/modules/pismo/services/pismo.service.ts
  2. Create src/modules/pismo/services/pismo-auth.service.ts (JWT handling)
  3. Create src/core/http/circuit-breaker.interceptor.ts
  4. Implement mTLS configuration in Axios
  5. Implement JWT token generation and caching with Redis
  6. Add comprehensive error handling and logging
Tool Usage:
  1. Read httphelper.js sections: certificate loading, JWT generation
  2. Write src/modules/pismo/services/pismo.service.ts
  3. Write src/modules/pismo/services/pismo-auth.service.ts
  4. Write src/core/http/circuit-breaker.interceptor.ts
  5. Write tests: src/modules/pismo/services/pismo.service.spec.ts
Success Criteria:
  - Unit tests >90% coverage
  - Integration test against Pismo sandbox succeeds
  - JWT token cached in Redis with 58-minute TTL
  - Circuit breaker trips after 3 consecutive failures
  - mTLS certificates loaded from Secret Manager
  - All errors logged with context
Testing Requirements:
  - Unit tests for JWT generation
  - Unit tests for circuit breaker logic
  - Integration test: create Pismo account in sandbox
  - Integration test: circuit breaker prevents cascading failures
Hard Rules:
  - NO hardcoded secrets
  - ALL certificates from Secret Manager
  - MUST implement retry with exponential backoff
Outputs:
  - src/modules/pismo/services/pismo.service.ts
  - src/modules/pismo/services/pismo-auth.service.ts
  - src/core/http/circuit-breaker.interceptor.ts
  - src/modules/pismo/services/pismo.service.spec.ts (tests)
  - migration_docs/agents/pismo-service-implementation-report.md
"

### 1.2 Implement Pismo Webhook Handlers
Use Task tool with subagent_type="api-architect"
Prompt:
"
Role: Backend Engineer
Objective: Implement webhook receivers with JWT verification, idempotency, and event queuing
Inputs:
  - migration_docs/agents/pismo-integration-design.md
  - Ignixxion.DM.API/functions/pismo/events.js (reference handlers)
  - migration_docs/AUTH_GAPS.md (AUTH-029: signature verification required)
Implementation:
  1. Create src/modules/pismo/controllers/webhooks.controller.ts
  2. Create src/modules/pismo/guards/webhook-signature.guard.ts
  3. Create src/modules/pismo/queues/pismo-events.processor.ts
  4. Create src/modules/pismo/dto/pismo-event.dto.ts
  5. Implement idempotency check (Redis cache of eventId)
  6. Implement dual-write: PostgreSQL + Firestore
Tool Usage:
  1. Read pismo/events.js (understand event types)
  2. Write src/modules/pismo/controllers/webhooks.controller.ts
  3. Write src/modules/pismo/guards/webhook-signature.guard.ts
  4. Write src/modules/pismo/queues/pismo-events.processor.ts
  5. Write tests with mock webhooks
Success Criteria:
  - Webhook signature verification passes with valid JWT
  - Webhook signature verification rejects invalid JWT
  - Duplicate events (same eventId) return 200 but don't reprocess
  - Events stored in PismoEvents table
  - Events queued for async processing
  - Dual-write to Firestore succeeds (or retries)
Testing Requirements:
  - Unit tests for signature verification
  - Unit tests for idempotency check
  - E2E test: send webhook, verify in database
  - E2E test: send duplicate webhook, verify not reprocessed
Hard Rules:
  - MUST verify JWT signature before processing
  - MUST validate body hash matches signature
  - MUST check timestamp (reject if >5 minutes old)
  - MUST store eventId for idempotency
Outputs:
  - src/modules/pismo/controllers/webhooks.controller.ts
  - src/modules/pismo/guards/webhook-signature.guard.ts
  - src/modules/pismo/queues/pismo-events.processor.ts
  - test/e2e/pismo-webhooks.e2e-spec.ts
  - migration_docs/agents/webhook-implementation-report.md
"

### 1.3 Validate Pismo Integration
Use Task tool with subagent_type="test-e2e"
Prompt:
"
Role: QA Engineer
Objective: Validate Pismo integration works end-to-end in sandbox environment
Inputs:
  - src/modules/pismo/services/pismo.service.ts
  - src/modules/pismo/controllers/webhooks.controller.ts
  - migration_docs/PARITY_REPORT.md (validation requirements)
Test Scenarios:
  1. JWT token generation and caching
  2. Create account in Pismo sandbox
  3. Create customer in Pismo sandbox
  4. Create card in Pismo sandbox
  5. Send webhook event, verify processing
  6. Send duplicate webhook, verify idempotency
  7. Circuit breaker behavior on failures
Tool Usage:
  1. Write test/integration/pismo-service.integration.spec.ts
  2. Write test/e2e/pismo-webhooks.e2e-spec.ts
  3. Bash: yarn test:e2e test/e2e/pismo-webhooks.e2e-spec.ts
  4. Grep pattern='✓' in test output (count passed tests)
Success Criteria:
  - All integration tests pass
  - All E2E tests pass
  - Circuit breaker trips and resets as expected
  - Webhook signature verification works
  - Idempotency prevents duplicate processing
Testing Requirements:
  - Test coverage >85%
  - Integration tests use Pismo sandbox (not production!)
  - Mock Firestore writes (don't write to production Firestore)
Outputs:
  - test/integration/pismo-service.integration.spec.ts
  - test/e2e/pismo-webhooks.e2e-spec.ts
  - migration_docs/agents/pismo-integration-test-report.md
"

### 1.99 Phase 1 Checkpoint & Progress Update
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Update Progress:
  1. Read migration_docs/progress-tracker.json
  2. Update:
     - phase_1.status = 'complete'
     - phase_1.completedAt = '[ISO timestamp]'
     - domains.pismo.completed += 2 (httphelper, webhooks)
     - completedFunctions += 2
     - completionPercentage = (completedFunctions / 93) * 100
  3. Write updated progress-tracker.json
  4. Regenerate migration_docs/PROGRESS.md dashboard
Update Artifacts:
  1. Read migration_docs/artifacts.json
  2. Find functions: 'handlePismoEvent', 'handlePismoEventProd'
  3. Update their status: 'todo' → 'completed'
  4. Add completedAt timestamp
  5. Add featureBranch: 'feature/pismo-integration'
  6. Write updated artifacts.json
Commit:
  - git add migration_docs/ src/ test/
  - git commit -m 'feat: complete Phase 1 - Pismo integration foundation

Implemented:
- PismoService with mTLS and JWT auth
- Circuit breaker for resilience
- Webhook handlers with signature verification
- Idempotent event processing
- Dual-write to PostgreSQL + Firestore

Functions completed: 2/93 (2.15%)
Tests: >85% coverage
Security: Fixed AUTH-029 (webhook signature verification)
'
  - git tag phase-1-complete
Outputs:
  - migration_docs/progress-tracker.json (updated)
  - migration_docs/artifacts.json (updated)
  - migration_docs/PROGRESS.md (regenerated)
  - migration_docs/agents/phase-1-completion-report.md
"

---

## Phase 2: Database Schema Optimization (NEW - Addresses BLOCKER Index Gaps)
**Priority:** HIGH (Performance foundation)
**Effort:** 1 week
**Functions:** N/A (infrastructure)

### 2.1 Schema Index Analysis
Use Task tool with subagent_type="schema-indexer"
Prompt:
"
Role: Database Performance Engineer
Objective: Analyze schema and recommend optimized indexes for multi-tenant queries
Inputs:
  - prisma/schema.prisma (18 models)
  - migration_docs/PARITY_REPORT.md (query patterns)
  - migration_docs/PHASE_2_BRIEFING.md (index gaps: 21 current, 68 recommended)
  - src/**/*.service.ts (query shapes from Prisma calls)
Analysis Focus:
  - All companyId fields MUST have indexes (multi-tenancy)
  - All foreign keys MUST have indexes (join performance)
  - Composite indexes for common query patterns
  - Indexes for RLS predicates (Supabase Row-Level Security)
Tool Usage:
  1. Read prisma/schema.prisma
  2. Grep pattern='findMany|findFirst|where.*companyId' in src/**/*.service.ts
  3. Grep pattern='@@index' in prisma/schema.prisma (find existing indexes)
  4. For each model, analyze:
     - Which fields used in WHERE clauses
     - Which fields used in ORDER BY clauses
     - Which fields used in JOINs
  5. Recommend indexes
Success Criteria:
  - Every companyId field has index
  - Every foreign key has index
  - Composite indexes for (companyId, status), (companyId, createdAt), etc.
  - No redundant indexes
  - Performance impact estimates provided
Hard Rules:
  - DO NOT remove existing indexes
  - Composite index order matters: (companyId, otherField) not (otherField, companyId)
  - Include EXPLAIN query examples
Outputs:
  - migration_docs/agents/index-recommendations.md
  - migration_docs/agents/performance-impact-estimates.md
"

### 2.2 Apply Index Migration
Use Task tool with subagent_type="schema-indexer"
Prompt:
"
Role: Database Engineer
Objective: Generate and apply Prisma migration for recommended indexes
Inputs:
  - migration_docs/agents/index-recommendations.md
  - prisma/schema.prisma
Implementation:
  1. Edit prisma/schema.prisma to add recommended @@index directives
  2. Examples:
     model Driver {
       ...
       companyUid String
       deleted Boolean @default(false)
       ...
       @@index([companyUid, deleted], name: 'idx_driver_company_active')
       @@index([companyUid, createdAt], name: 'idx_driver_company_created')
     }
  3. Generate migration:
     - Bash: npx prisma migrate dev --name add_performance_indexes
  4. Test with EXPLAIN queries
Tool Usage:
  1. Read index-recommendations.md
  2. Edit prisma/schema.prisma (add @@index directives)
  3. Bash: npx prisma format (format schema)
  4. Bash: npx prisma migrate dev --name add_performance_indexes
  5. Bash: npx prisma migrate deploy (apply to dev database)
  6. Write EXPLAIN query tests
Success Criteria:
  - Migration generated successfully
  - Migration applied to dev database
  - EXPLAIN queries show index usage
  - No sequential scans on large tables
  - Rollback script created
Testing Requirements:
  - Test EXPLAIN for common queries:
    SELECT * FROM drivers WHERE companyUid = '...' AND deleted = false;
    (should use idx_driver_company_active)
  - Verify query performance improvement (benchmark before/after)
Hard Rules:
  - Test migration in dev BEFORE production
  - Create rollback migration
  - Document performance improvements
Outputs:
  - prisma/migrations/[timestamp]_add_performance_indexes/migration.sql
  - migration_docs/agents/index-migration-report.md
  - migration_docs/agents/index-rollback-plan.md
"

### 2.99 Phase 2 Checkpoint
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Update Progress:
  - phase_2.status = 'complete'
  - phase_2.completedAt = '[ISO timestamp]'
  - Update PROGRESS.md: 'Phase 2: Database optimized with 68 indexes'
Commit:
  - git add prisma/ migration_docs/
  - git commit -m 'perf: add database indexes for multi-tenant queries

Added 47 new indexes:
- companyId indexes on all entities
- Composite indexes for common query patterns
- Foreign key indexes for join performance

Performance improvement: 50-200x on filtered queries
'
  - git tag phase-2-complete
Outputs:
  - migration_docs/progress-tracker.json (updated)
  - migration_docs/PROGRESS.md (regenerated)
  - migration_docs/agents/phase-2-completion-report.md
"

---

## Phase 3: High-Priority API Surfaces (Card Operations)
**Priority:** HIGH
**Effort:** 2-3 weeks
**Functions:** 12 card management functions

### 3.1 Card API Specifications
Use Task tool with subagent_type="api-architect"
Prompt:
"
Role: API Designer
Objective: Design complete card management API specs per QUICK_REFERENCE.md priority
Inputs:
  - migration_docs/FUNCTION_MAPPING.md (card functions)
  - migration_docs/QUICK_REFERENCE.md (priority: createCardPismo, updateCardStatusPismo, etc.)
  - Ignixxion.DM.API/functions/pismo/cards.js (reference implementation)
  - migration_docs/agents/pismo-service-class-diagram.md
Functions to Specify (12 total):
  1. createCardPismo → POST /api/v1/cards
  2. updateCardPismo → PATCH /api/v1/cards/:id
  3. updateCardStatusPismo → PATCH /api/v1/cards/:id/status
  4. setCardEnable → POST /api/v1/cards/:id/enable
  5. setCardDisable → POST /api/v1/cards/:id/disable
  6. getCardsPismo → GET /api/v1/cards
  7. getCardStatusPismo → GET /api/v1/cards/:id/status
  8. getCurrentCardStatusPismo → GET /api/v1/cards/:id/current-status
  9. getCardStatusListPismo → GET /api/v1/cards/status-list
  10. getCardAuthorizations → GET /api/v1/cards/:id/authorizations
  11. issueCard → POST /api/v1/cards/issue
  12. handleUpdateCardToS → POST /api/v1/cards/:id/accept-tos
For Each Endpoint:
  - HTTP method and path
  - Auth requirements (roles: admin, fleet_manager)
  - Request DTO with validation rules
  - Response DTO with examples
  - Error codes (400, 401, 403, 404, 500)
  - Idempotency header requirements
  - Rate limits
  - Dual-write behavior (PostgreSQL + Firestore)
Tool Usage:
  1. Read pismo/cards.js (extract request/response shapes)
  2. Read FUNCTION_MAPPING.md (card section)
  3. For each function, write detailed spec
Success Criteria:
  - All 12 functions have complete specs
  - DTOs include all validation rules (@IsString, @IsNotEmpty, etc.)
  - Auth requirements specified per endpoint
  - Dual-write strategy defined
  - Pismo API mapping documented
Hard Rules:
  - Preserve Firebase function names (no renames)
  - Multi-tenant isolation (companyId required)
  - Audit logging on create/update/delete
Outputs:
  - migration_docs/agents/specs-cards.md (all 12 endpoints)
  - migration_docs/agents/cards-dto-definitions.md
"

### 3.2 Generate Card Module Scaffolds
Use Task tool with subagent_type="api-architect"
Prompt:
"
Role: Backend Engineer
Objective: Generate complete card module implementation per specs
Inputs:
  - migration_docs/agents/specs-cards.md
  - migration_docs/agents/pismo-service-class-diagram.md
  - src/modules/pismo/services/pismo.service.ts (use for Pismo API calls)
Implementation:
  1. Generate src/modules/cards/cards.module.ts
  2. Generate src/modules/cards/cards.controller.ts (all 12 endpoints)
  3. Generate src/modules/cards/cards.service.ts (business logic + dual-write)
  4. Generate src/modules/cards/dto/*.dto.ts (Create, Update, Query, Response DTOs)
  5. Add @ApiTags, @ApiOperation, @ApiResponse decorators
  6. Add @UseGuards(FirebaseAuthGuard, RolesGuard)
  7. Add @Roles decorators per spec
  8. Implement multi-tenant filtering (companyId)
  9. Implement audit logging
  10. Implement dual-write (PostgreSQL + Firestore with retry)
Tool Usage:
  1. Read specs-cards.md
  2. Write src/modules/cards/cards.module.ts
  3. Write src/modules/cards/cards.controller.ts
  4. Write src/modules/cards/cards.service.ts
  5. Write src/modules/cards/dto/create-card.dto.ts (and all other DTOs)
  6. Write tests: src/modules/cards/cards.service.spec.ts
Success Criteria:
  - All 12 endpoints implemented
  - Unit tests >80% coverage
  - Integration tests with Pismo sandbox pass
  - Multi-tenant isolation verified
  - Swagger docs generated
Testing Requirements:
  - Unit tests for each service method
  - Mock PrismaService and PismoService
  - Test multi-tenant isolation (user1 cannot access user2's cards)
  - Integration test: create card in Pismo sandbox
Hard Rules:
  - ALL queries MUST filter by companyId
  - ALL mutations MUST log to audit_logs table
  - ALL Pismo API calls MUST use circuit breaker
Outputs:
  - src/modules/cards/** (complete module)
  - src/modules/cards/cards.service.spec.ts (tests)
  - migration_docs/agents/cards-implementation-report.md
"

### 3.3 Update Function Mapping
Use Task tool with subagent_type="function-mapper"
Prompt:
"
Role: Documentation Engineer
Objective: Update FUNCTION_MAPPING.md with completed card endpoints
Inputs:
  - migration_docs/FUNCTION_MAPPING.md
  - src/modules/cards/cards.controller.ts (implemented endpoints)
Updates:
  1. For each of 12 card functions, update status: 'todo' → 'completed'
  2. Add NestJS route (POST /api/v1/cards, etc.)
  3. Add controller name (CardsController)
  4. Add service name (CardsService)
  5. Add DTO names (CreateCardDto, UpdateCardDto, etc.)
  6. Add completion timestamp
Tool Usage:
  1. Read FUNCTION_MAPPING.md
  2. Read cards.controller.ts (extract routes and decorators)
  3. Edit FUNCTION_MAPPING.md (update card section)
  4. Write updated file
Success Criteria:
  - All 12 card functions marked as 'completed'
  - Routes accurately reflect implementation
  - No endpoint renames without change record
Outputs:
  - migration_docs/FUNCTION_MAPPING.md (updated)
  - migration_docs/agents/function-mapping-delta.md (what changed)
"

### 3.99 Phase 3 Checkpoint & Progress Update
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Update Progress:
  - phase_3.status = 'complete'
  - domains.pismo.completed += 12 (card functions)
  - completedFunctions += 12
  - completionPercentage = (completedFunctions / 93) * 100
Update Artifacts:
  - Update artifacts.json: Mark 12 card functions as 'completed'
Commit:
  - git add src/modules/cards migration_docs/
  - git commit -m 'feat: implement card management module (12 endpoints)

Implemented:
- Create, update, enable/disable cards
- Card status and authorization queries
- Integration with PismoService
- Multi-tenant isolation
- Dual-write to PostgreSQL + Firestore
- Audit logging0

Functions completed: 14/93 (15.05%)
Tests: >80% coverage
'
  - git tag phase-3-complete
Outputs:
  - migration_docs/progress-tracker.json (updated)
  - migration_docs/artifacts.json (updated)
  - migration_docs/PROGRESS.md (regenerated)
"

---

## Phase 4: Auth & Security Hardening
**Priority:** HIGH (Fixes AUTH_GAPS.md critical issues)
**Effort:** 2 weeks
**Functions:** N/A (infrastructure)

### 4.1 Design RBAC Model
Use Task tool with subagent_type="auth-security"
Prompt:
"
Role: Security Architect
Objective: Design unified RBAC model addressing all 10 critical security issues from AUTH_GAPS.md
Inputs:
  - migration_docs/AUTH_GAPS.md (10 critical issues)
  - migration_docs/FUNCTION_MAPPING.md (endpoint permissions)
  - migration_docs/artifacts.json (all functions)
Security Issues to Address:
  - AUTH-023: Zero tenant isolation (add companyId filtering)
  - AUTH-024: No Row-Level Security in PostgreSQL
  - AUTH-029: Pismo webhook signature verification (DONE in Phase 1)
  - [List remaining 7 issues from AUTH_GAPS.md]
RBAC Design:
  1. Roles:
     - super_admin (platform-wide access)
     - admin (company admin)
     - fleet_manager (fleet operations)
     - driver (driver-only access)
     - readonly (read-only access)
  2. Permissions per endpoint:
     - companies:read, companies:write
     - drivers:read, drivers:write
     - cards:read, cards:write
     - transactions:read
     - reports:read
  3. Tenant Isolation Rules:
     - All queries MUST filter by user.companyId
     - super_admin bypasses (but logs access)
     - Cross-tenant access returns 403
  4. Rate Limiting:
     - Global: 100 req/min per IP
     - Auth endpoints: 5 req/min
     - Mutations: 20 req/min
Tool Usage:
  1. Read AUTH_GAPS.md thoroughly
  2. For each security issue, design mitigation
  3. Define role hierarchy
  4. Map permissions to endpoints
Success Criteria:
  - All 10 security issues addressed
  - Role hierarchy defined
  - Permission matrix complete
  - Tenant isolation rules documented
  - Rate limiting policies defined
Hard Rules:
  - Multi-tenant isolation is MANDATORY (not optional)
  - super_admin access is LOGGED (audit trail)
  - Rate limits CANNOT be disabled
Outputs:
  - migration_docs/agents/rbac-model.md
  - migration_docs/agents/tenant-isolation-rules.md
  - migration_docs/agents/rate-limiting-policy.md
  - migration_docs/agents/security-issues-resolution.md
"

### 4.2 Implement Auth Guards & Decorators
Use Task tool with subagent_type="auth-security"
Prompt:
"
Role: Security Engineer
Objective: Implement complete auth infrastructure per RBAC model
Inputs:
  - migration_docs/agents/rbac-model.md
  - migration_docs/agents/tenant-isolation-rules.md
  - migration_docs/AUTH_GAPS.md
Implementation:
  1. Enhance src/core/auth/guards/firebase-auth.guard.ts
  2. Create src/core/auth/guards/roles.guard.ts
  3. Create src/core/auth/guards/permissions.guard.ts
  4. Create src/core/auth/decorators/roles.decorator.ts
  5. Create src/core/auth/decorators/permissions.decorator.ts
  6. Create src/core/security/rate-limit.interceptor.ts
  7. Create src/core/security/tenant-isolation.interceptor.ts
  8. Configure Row-Level Security (RLS) in Supabase (SQL scripts)
Tool Usage:
  1. Read rbac-model.md and tenant-isolation-rules.md
  2. Write guard implementations
  3. Write decorator implementations
  4. Write interceptor implementations
  5. Write Supabase RLS policies (SQL)
  6. Write comprehensive tests
Success Criteria:
  - All controllers have @UseGuards(FirebaseAuthGuard)
  - All mutation endpoints have @Roles decorators
  - All queries filter by user.companyId
  - Cross-tenant access attempts return 403
  - Rate limiting enforced globally
  - RLS policies active in database
Testing Requirements:
  - Unit tests for all guards (>90% coverage)
  - E2E tests for cross-tenant isolation
  - E2E tests for rate limiting
  - E2E tests for role enforcement
  - Test RLS policies with SQL queries
Hard Rules:
  - ZERO endpoints without auth guards
  - ZERO queries without companyId filter (except super_admin with logging)
  - Rate limits CANNOT be bypassed
Outputs:
  - src/core/auth/guards/*.guard.ts
  - src/core/auth/decorators/*.decorator.ts
  - src/core/security/*.interceptor.ts
  - prisma/rls-policies.sql (Supabase RLS)
  - test/e2e/auth-security.e2e-spec.ts
  - migration_docs/agents/auth-implementation-report.md
"

### 4.3 Security Audit & Validation
Use Task tool with subagent_type="auth-security"
Prompt:
"
Role: Security Auditor
Objective: Validate all 10 critical security issues from AUTH_GAPS.md are resolved
Inputs:
  - migration_docs/AUTH_GAPS.md (10 issues)
  - migration_docs/agents/security-issues-resolution.md
  - src/core/auth/** (guard implementations)
  - src/**/*.controller.ts (all controllers)
Audit Checklist:
  1. Scan all controllers for missing @UseGuards
  2. Scan all mutation endpoints for missing @Roles
  3. Scan all service methods for missing companyId filters
  4. Test cross-tenant access (must fail with 403)
  5. Test rate limiting (must return 429 when exceeded)
  6. Verify Pismo webhook signature validation
  7. Check for hardcoded secrets (must be zero)
  8. Run npm audit (must show 0 critical vulnerabilities)
Tool Usage:
  1. Grep pattern='@Controller' in src/**/*.controller.ts
  2. Grep pattern='@UseGuards' in src/**/*.controller.ts (count matches)
  3. Compare counts (must be equal)
  4. Grep pattern='@Post|@Patch|@Put|@Delete' (find mutations)
  5. Grep pattern='@Roles' near mutations (verify all have roles)
  6. Grep pattern='findMany|findFirst' in src/**/*.service.ts
  7. Check if all have 'where.*companyId'
  8. Run E2E tests for security scenarios
  9. Bash: npm audit
Success Criteria:
  - 100% of controllers have @UseGuards
  - 100% of mutation endpoints have @Roles
  - 100% of queries filter by companyId (or explicitly super_admin with logging)
  - All cross-tenant tests return 403
  - All rate limit tests return 429 when exceeded
  - Webhook signature tests pass
  - npm audit shows 0 critical issues
  - All 10 AUTH_GAPS.md issues marked as RESOLVED
Outputs:
  - migration_docs/agents/security-audit-report.md (PASS/FAIL per issue)
  - migration_docs/agents/security-coverage-matrix.md
"

### Gate S: Security Validation (NEW - AUTOMATED)
Use Task tool with subagent_type="auth-security"
Prompt:
"
Role: Quality Gate Enforcer
Objective: Automated security gate - BLOCK if any security issue detected
Validation:
  1. Read security-audit-report.md
  2. Parse PASS/FAIL status per issue
  3. Count FAIL items
  4. If FAIL count > 0:
     - Output JSON: {'status': 'FAIL', 'issues': [...]}
     - BLOCK progression to Phase 5
     - List specific failures
  5. Else:
     - Output JSON: {'status': 'PASS', 'coverage': '100%'}
     - Allow progression
Success Criteria:
  - Gate outputs valid JSON
  - Gate blocks on any FAIL
  - Failures are actionable
Output:
  - migration_docs/agents/gate-s-validation.json
"

GATE ENFORCEMENT:
IF gate-s-validation.json status == 'FAIL':
  - STOP workflow
  - Display failures to user
  - Require auth-security to fix issues
  - Re-run Phase 4.3 security audit
  - Re-run Gate S
ELSE:
  - Log: 'Gate S PASSED - All security issues resolved'
  - Proceed to Phase 4.99

### 4.99 Phase 4 Checkpoint
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Update Progress:
  - phase_4.status = 'complete'
  - blockers: Remove 'BLOCKER-5: Security Vulnerabilities'
Commit:
  - git add src/core/auth src/core/security migration_docs/
  - git commit -m 'feat: implement complete auth and security infrastructure

Implemented:
- RBAC with roles and permissions
- Multi-tenant isolation guards
- Rate limiting
- Row-Level Security (RLS)
- Cross-tenant access prevention

Security Issues Resolved: 10/10 (100%)
Gate S: PASSED
'
  - git tag phase-4-complete
"

---

## Phase 5: Swagger Documentation & Validation
**Priority:** HIGH
**Effort:** 1 week
**Functions:** N/A (documentation)

### 5.1 Swagger Coverage Analysis
Use Task tool with subagent_type="swagger-qa"
Prompt:
"
Role: API Documentation Lead
Objective: Analyze current Swagger coverage and create completion checklist
Inputs:
  - migration_docs/swagger-coverage-report.md (0.68% coverage)
  - migration_docs/FUNCTION_MAPPING.md (endpoints to document)
  - src/**/*.controller.ts (current controllers)
  - src/**/*.dto.ts (current DTOs)
Analysis:
  1. Scan all controllers for @ApiTags
  2. Scan all endpoints for @ApiOperation
  3. Scan all endpoints for @ApiResponse (200/201, 400, 401, 403, 500)
  4. Scan all DTOs for @ApiProperty
  5. Generate checklist of missing decorators
Tool Usage:
  1. Glob src/**/*.controller.ts
  2. For each controller:
     - Grep '@ApiTags' (check if present)
     - Grep '@ApiOperation' (count vs endpoint count)
     - Grep '@ApiResponse' (count vs endpoint count × 4)
  3. Glob src/**/*.dto.ts
  4. For each DTO:
     - Grep '@ApiProperty' (count vs field count)
  5. Generate checklist
Success Criteria:
  - Complete list of controllers needing @ApiTags
  - Complete list of endpoints needing @ApiOperation
  - Complete list of endpoints needing @ApiResponse
  - Complete list of DTOs needing @ApiProperty
  - Checklist is actionable (file:line references)
Outputs:
  - migration_docs/agents/swagger-checklist.md
  - migration_docs/agents/swagger-coverage-analysis.md
"

### 5.2 Add Swagger Decorators
Use Task tool with subagent_type="swagger-qa"
Prompt:
"
Role: Documentation Engineer
Objective: Add all missing Swagger decorators to achieve 100% coverage
Inputs:
  - migration_docs/agents/swagger-checklist.md
  - src/**/*.controller.ts
  - src/**/*.dto.ts
Implementation:
  1. For each controller without @ApiTags, add it
  2. For each endpoint without @ApiOperation, add with summary and description
  3. For each endpoint without @ApiResponse, add for status codes: 200/201, 400, 401, 403, 500
  4. For each DTO without @ApiProperty, add with description and example
  5. Generate swagger.json
  6. Validate with swagger-cli
Tool Usage:
  1. Read swagger-checklist.md
  2. For each missing decorator:
     - Edit file and add decorator
  3. Bash: yarn build && yarn start:dev &
  4. Bash: curl http://localhost:3000/api/v1/docs-json > swagger.json
  5. Bash: npx swagger-cli validate swagger.json
Success Criteria:
  - All controllers have @ApiTags
  - All endpoints have @ApiOperation with summary
  - All endpoints have @ApiResponse for all status codes
  - All DTOs have @ApiProperty with description and example
  - swagger.json validates successfully
  - Coverage = 100%
Hard Rules:
  - Descriptions must be meaningful (not just 'Get data')
  - Examples must be realistic
  - Error responses must include error schema
Outputs:
  - Updated src/**/*.controller.ts files
  - Updated src/**/*.dto.ts files
  - swagger.json (generated)
  - migration_docs/agents/swagger-implementation-report.md
"

### Gate D: Swagger Coverage (AUTOMATED)
Use Task tool with subagent_type="swagger-qa"
Prompt:
"
Role: Quality Gate Enforcer
Objective: Validate 100% Swagger coverage
Validation:
  1. Bash: yarn build
  2. Bash: yarn start:dev &
  3. Bash: sleep 5 (wait for server)
  4. Bash: curl http://localhost:3000/api/v1/docs-json > swagger.json
  5. Bash: npx swagger-cli validate swagger.json (must succeed)
  6. Read swagger.json
  7. Extract all paths (endpoints)
  8. For each endpoint, verify:
     - Has 'summary' field (from @ApiOperation)
     - Has 'responses' object with keys: 200/201, 400, 401, 403, 500
     - Request schema has 'properties' with descriptions
     - Response schema has 'properties' with descriptions
  9. Calculate coverage: (documented endpoints / total endpoints) × 100
  10. If coverage < 100%:
      - List undocumented endpoints
      - Output JSON: {'status': 'FAIL', 'coverage': X, 'failures': [...]}
  11. Else:
      - Output JSON: {'status': 'PASS', 'coverage': 100}
Outputs:
  - swagger.json
  - migration_docs/agents/gate-d-validation.json
"

GATE ENFORCEMENT:
IF gate-d-validation.json status == 'FAIL':
  - STOP workflow
  - Display undocumented endpoints
  - Require swagger-qa to add missing decorators
  - Re-run Phase 5.2
  - Re-run Gate D
ELSE:
  - Log: 'Gate D PASSED - 100% Swagger coverage'
  - Proceed to Phase 5.99

### 5.99 Phase 5 Checkpoint
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Update Progress:
  - phase_5.status = 'complete'
Commit:
  - git add src/ swagger.json migration_docs/
  - git commit -m 'docs: achieve 100% Swagger API documentation coverage

Added complete Swagger decorators:
- @ApiTags on all controllers
- @ApiOperation on all endpoints
- @ApiResponse for all status codes
- @ApiProperty on all DTOs

Coverage: 100% (was 0.68%)
Gate D: PASSED
'
  - git tag phase-5-complete
"

---

## Phase 6: Testing & Parity Validation
**Priority:** HIGH (Quality assurance)
**Effort:** 2 weeks
**Functions:** N/A (testing infrastructure)

### 6.1 Test Plan Design
Use Task tool with subagent_type="test-e2e"
Prompt:
"
Role: Test Architect
Objective: Design comprehensive test plan for migrated functionality
Inputs:
  - migration_docs/PARITY_REPORT.md (parity requirements)
  - migration_docs/FUNCTION_MAPPING.md (all endpoints)
  - migration_docs/progress-tracker.json (completed functions)
  - Ignixxion.DM.API/functions (Firebase reference)
Test Plan Structure:
  1. Unit Tests:
     - All services (>80% coverage target)
     - All guards and decorators
     - All DTOs validation
  2. Integration Tests:
     - Database operations (Prisma)
     - Pismo API calls (sandbox)
     - Cache operations (Redis)
     - Queue processing (Bull)
  3. E2E Tests:
     - Happy paths (CRUD operations)
     - Unhappy paths (errors, validation)
     - Auth flows (login, permissions, isolation)
     - Performance (response times)
  4. Contract Tests:
     - Generate from swagger.json
     - Validate request/response schemas
  5. Replay Tests:
     - Capture Firebase function requests
     - Replay against NestJS endpoints
     - Verify identical responses
Tool Usage:
  1. Read PARITY_REPORT.md (understand parity requirements)
  2. Read FUNCTION_MAPPING.md (completed endpoints)
  3. For each completed function, define test scenarios
  4. Group tests by type
Success Criteria:
  - Test plan covers all migrated endpoints
  - Unit test target: >80% coverage
  - E2E tests cover all critical paths
  - Replay tests defined for high-priority functions
  - Performance benchmarks defined
Outputs:
  - migration_docs/agents/test-plan.md
  - migration_docs/agents/replay-harness-design.md
  - migration_docs/agents/performance-benchmarks.md
"

### 6.2 Generate Test Suites
Use Task tool with subagent_type="test-e2e"
Prompt:
"
Role: QA Engineer
Objective: Generate complete test suites per test plan
Inputs:
  - migration_docs/agents/test-plan.md
  - swagger.json (for contract tests)
  - migration_docs/agents/replay-harness-design.md
Implementation:
  1. Unit Tests:
     - Generate tests for all services
     - Mock Prisma, PismoService, CacheService
     - Test business logic in isolation
  2. Integration Tests:
     - Test database operations with test database
     - Test Pismo API calls with sandbox
     - Test cache with test Redis
  3. E2E Tests:
     - Test full request/response cycles
     - Test auth flows
     - Test multi-tenant isolation
     - Test error scenarios
  4. Contract Tests:
     - Use swagger.json to generate tests
     - Validate all request/response schemas
  5. Replay Tests:
     - Implement harness to replay Firebase requests
     - Compare responses with Firebase baseline
Tool Usage:
  1. Read test-plan.md
  2. For each test type, generate test files
  3. Write test/unit/**/*.spec.ts
  4. Write test/integration/**/*.integration.spec.ts
  5. Write test/e2e/**/*.e2e-spec.ts
  6. Write test/contract/**/*.contract.spec.ts
  7. Write test/replay/replay-harness.ts
Success Criteria:
  - All test files generated
  - Unit tests compile and run
  - Integration tests use test database
  - E2E tests use test environment
  - Contract tests validate all endpoints
  - Replay harness functional
Testing Requirements:
  - Unit tests: >80% coverage
  - Integration tests: All Pismo operations tested in sandbox
  - E2E tests: All critical paths covered
  - Contract tests: 100% of endpoints validated
Hard Rules:
  - NO tests against production database
  - NO tests against production Pismo
  - ALL tests must be idempotent
  - Mock external dependencies in unit tests
Outputs:
  - test/unit/**/*.spec.ts
  - test/integration/**/*.integration.spec.ts
  - test/e2e/**/*.e2e-spec.ts
  - test/contract/**/*.contract.spec.ts
  - test/replay/replay-harness.ts
  - migration_docs/agents/test-implementation-report.md
"

### 6.3 Run Test Suites & Validate Coverage
Use Task tool with subagent_type="test-e2e"
Prompt:
"
Role: QA Lead
Objective: Run all test suites and validate coverage meets thresholds
Test Execution:
  1. Run unit tests with coverage:
     - Bash: yarn test --coverage
     - Parse coverage report
     - Verify >80% lines, statements, functions, branches
  2. Run integration tests:
     - Bash: yarn test:integration
     - Verify all pass
  3. Run E2E tests:
     - Bash: yarn test:e2e
     - Verify all pass
  4. Run contract tests:
     - Bash: yarn test:contract
     - Verify all pass
  5. Run replay tests:
     - Bash: yarn test:replay
     - Compare response shapes
Tool Usage:
  1. Bash: yarn test --coverage
  2. Read coverage/coverage-summary.json
  3. Parse coverage percentages
  4. Bash: yarn test:integration
  5. Bash: yarn test:e2e
  6. Bash: yarn test:contract
  7. Bash: yarn test:replay
  8. Collect results
Success Criteria:
  - Unit test coverage >80% (all metrics)
  - All integration tests pass
  - All E2E tests pass
  - All contract tests pass
  - Replay tests show >95% parity
Outputs:
  - coverage/coverage-summary.json
  - migration_docs/agents/test-results-report.md
  - migration_docs/agents/coverage-report.md
"

### 6.4 Parity Validation
Use Task tool with subagent_type="migration-verifier"
Prompt:
"
Role: Quality Assurance Engineer
Objective: Validate functional parity between Firebase and NestJS implementations
Inputs:
  - migration_docs/PARITY_REPORT.md (parity requirements)
  - migration_docs/FUNCTION_MAPPING.md (completed functions)
  - Ignixxion.DM.API/functions (Firebase reference)
  - IgnixxionNestAPI/src (NestJS implementation)
  - test/replay/results/*.json (replay test results)
Validation:
  1. For each completed function:
     - Compare request/response shapes (must match)
     - Compare status codes (must match)
     - Compare error messages (should match)
     - Compare data transformations (must match)
     - Verify multi-tenant isolation (NestJS must enforce)
  2. Run parity queries from PARITY_REPORT.md
  3. Compare Firebase and PostgreSQL data counts
  4. Identify discrepancies
Tool Usage:
  1. Read PARITY_REPORT.md (validation queries)
  2. Read FUNCTION_MAPPING.md (completed functions)
  3. For each function:
     - Read Firebase implementation
     - Read NestJS implementation
     - Compare logic
  4. Run validation queries against both databases
  5. Run replay tests and analyze results
Success Criteria:
  - 100% parity on CRITICAL endpoints (Pismo webhooks, card ops)
  - >95% parity on HIGH priority endpoints
  - All discrepancies documented with justification
  - Zero CRITICAL discrepancies
  - Data counts match (Firebase vs PostgreSQL)
Outputs:
  - migration_docs/agents/parity-validation-report.md
  - migration_docs/agents/parity-discrepancies.md (if any)
"

### Gate E: Testing & Parity (AUTOMATED)
Use Task tool with subagent_type="test-e2e"
Prompt:
"
Role: Quality Gate Enforcer
Objective: Validate all tests pass and parity is achieved
Validation:
  1. Read coverage/coverage-summary.json
  2. Check total.lines.pct >= 80
  3. Check total.statements.pct >= 80
  4. Check total.functions.pct >= 80
  5. Check total.branches.pct >= 80
  6. Read test-results-report.md
  7. Verify all test suites passed
  8. Read parity-validation-report.md
  9. Count CRITICAL discrepancies
  10. If any failures:
      - Output JSON: {'status': 'FAIL', 'issues': [...]}
  11. Else:
      - Output JSON: {'status': 'PASS', 'coverage': X, 'parity': Y}
Outputs:
  - migration_docs/agents/gate-e-validation.json
"

GATE ENFORCEMENT:
IF gate-e-validation.json status == 'FAIL':
  - STOP workflow
  - Display failures (low coverage, test failures, parity issues)
  - Require test-e2e to fix issues
  - Re-run Phase 6.3
  - Re-run Gate E
ELSE:
  - Log: 'Gate E PASSED - Tests and parity validated'
  - Proceed to Phase 6.99

### 6.99 Phase 6 Checkpoint
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Update Progress:
  - phase_6.status = 'complete'
Commit:
  - git add test/ migration_docs/
  - git commit -m 'test: complete test infrastructure and parity validation

Implemented:
- Unit tests (>80% coverage)
- Integration tests (Pismo sandbox)
- E2E tests (critical paths)
- Contract tests (from Swagger)
- Replay harness (Firebase parity)

Coverage: 85%
Parity: >95% on all endpoints
Gate E: PASSED
'
  - git tag phase-6-complete
"

---

## Phase 7: CI/CD Pipeline Hardening
**Priority:** MEDIUM
**Effort:** 1 week
**Functions:** N/A (infrastructure)

### 7.1 CI/CD Pipeline Audit
Use Task tool with subagent_type="ci-cd-sentinel"
Prompt:
"
Role: DevOps Engineer
Objective: Audit CI/CD pipeline and ensure all quality gates are enforced
Inputs:
  - .github/workflows/ci-cd.yml
  - .github/workflows/security.yml
  - .github/workflows/database-migration.yml
  - package.json (scripts)
  - migration_docs/PHASE_2_BRIEFING.md (pipeline status)
Audit Checklist:
  1. Lint step present (yarn lint)
  2. Type-check step present (yarn typecheck)
  3. Build step present (yarn build)
  4. Unit test step present (yarn test)
  5. Coverage upload present (Codecov/Coveralls)
  6. E2E test step present (yarn test:e2e)
  7. Security scans present (Trivy, GitLeaks, Semgrep, CodeQL)
  8. Prisma migration step present (npx prisma migrate deploy)
  9. Swagger generation and publishing
  10. Gradual rollout configuration
Hardening Opportunities:
  - Enforce coverage thresholds (block if <80%)
  - Enforce security scan failures (block if critical issues)
  - Add automated rollback on deployment failure
  - Add integration/load testing before production
Tool Usage:
  1. Read .github/workflows/*.yml
  2. Grep pattern='yarn lint|yarn typecheck|yarn build|yarn test'
  3. Grep pattern='prisma migrate deploy'
  4. Check for coverage threshold enforcement
  5. Check for security scan blocking conditions
Success Criteria:
  - All 10 audit checklist items present
  - Coverage threshold enforced as BLOCKING
  - Security scans enforced as BLOCKING
  - Gradual rollout configured
Outputs:
  - migration_docs/agents/ci-cd-audit-report.md
  - migration_docs/agents/ci-cd-hardening-recommendations.md
"

### 7.2 Harden CI/CD Pipeline
Use Task tool with subagent_type="ci-cd-sentinel"
Prompt:
"
Role: DevOps Engineer
Objective: Implement all hardening recommendations from audit
Inputs:
  - migration_docs/agents/ci-cd-hardening-recommendations.md
  - .github/workflows/*.yml
Implementation:
  1. Enforce coverage thresholds:
     - Add step to check coverage/coverage-summary.json
     - Fail build if any metric <80%
  2. Enforce security scan failures:
     - Set trivy to fail on HIGH/CRITICAL
     - Set semgrep to fail on errors
     - Set codeql to fail on vulnerabilities
  3. Add swagger publishing:
     - Generate swagger.json in build
     - Upload as artifact
     - Publish to docs site
  4. Configure gradual rollout:
     - Set traffic split: 10% → 25% → 50% → 100%
     - Add health check gates between stages
  5. Add automated rollback:
     - Monitor error rate
     - Rollback if error rate >1% for 5 minutes
Tool Usage:
  1. Read ci-cd-hardening-recommendations.md
  2. Edit .github/workflows/ci-cd.yml
  3. Add coverage threshold check
  4. Add security scan failure conditions
  5. Add swagger publishing step
  6. Add gradual rollout configuration
  7. Commit changes
Success Criteria:
  - Coverage threshold enforced (blocks deploy if <80%)
  - Security scans enforced (blocks deploy if critical issues)
  - Swagger published as artifact
  - Gradual rollout configured
  - Automated rollback configured
Outputs:
  - .github/workflows/ci-cd.yml (updated)
  - .github/workflows/security.yml (updated)
  - migration_docs/agents/ci-cd-implementation-report.md
"

### 7.99 Phase 7 Checkpoint
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Update Progress:
  - phase_7.status = 'complete'
  - blockers: Update 'Testing Infrastructure' from 'In Progress' to 'Complete'
Commit:
  - git add .github/workflows/ migration_docs/
  - git commit -m 'ci: harden CI/CD pipeline with quality gates

Implemented:
- Coverage threshold enforcement (>80%)
- Security scan blocking (critical issues)
- Swagger artifact publishing
- Gradual rollout configuration
- Automated rollback on errors

Pipeline Status: Production-ready
'
  - git tag phase-7-complete
"

---

## Phase 8: Deployment & Rollout
**Priority:** HIGH
**Effort:** 2 weeks
**Functions:** N/A (deployment)

### 8.1 Pre-Deployment Validation
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Role: Release Manager
Objective: Final pre-deployment validation checklist
Validation Checklist:
  1. All gates passed:
     - Gate S (Security): PASSED
     - Gate D (Swagger): PASSED
     - Gate E (Testing & Parity): PASSED
  2. Code quality:
     - Coverage >80%
     - Zero critical security issues
     - All tests passing
  3. Database ready:
     - Migrations tested
     - Indexes applied
     - RLS policies active
  4. Infrastructure ready:
     - Cloud Run deployed
     - Supabase PostgreSQL connected
     - Redis Memorystore connected
     - Secret Manager configured
  5. Monitoring ready:
     - Cloud Logging enabled
     - Error tracking configured
     - Alerting rules set
  6. Rollback ready:
     - Firebase Functions still deployed
     - Dual-write active
     - Traffic routing configured
Tool Usage:
  1. Read all gate-*-validation.json files
  2. Verify all status == 'PASS'
  3. Read progress-tracker.json
  4. Verify completion percentage
  5. Read coverage/coverage-summary.json
  6. Verify coverage >80%
  7. Check infrastructure status
Success Criteria:
  - All validation checks pass
  - No blockers remaining
  - Rollback plan tested
Outputs:
  - migration_docs/agents/pre-deployment-validation.md (READY/NOT READY)
"

### 8.2 Staged Rollout Plan
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Role: Deployment Engineer
Objective: Execute staged rollout per PHASE_2_BRIEFING.md plan
Rollout Stages (from PHASE_2_BRIEFING.md):
  1. Internal Testing (0.1% traffic, 2 days)
     - Target: Internal team (5-10 users)
     - Success: Error rate <1%, P95 <200ms
  2. Beta Users (5% traffic, 3 days)
     - Target: Friendly customers (50-100 users)
     - Success: Error rate <0.5%, P95 <150ms
  3. Gradual - 25% (2 days)
     - Success: Error rate <0.3%
  4. Gradual - 50% (2 days)
     - Success: Error rate <0.2%
  5. Gradual - 75% (2 days)
     - Success: Error rate <0.1%
  6. Full Rollout - 100% (ongoing)
     - Success: Error rate <0.1%, P95 <150ms
Abort Rules (from PHASE_2_BRIEFING.md):
  - Error rate >1% for 5 minutes → ROLLBACK
  - P95 response time >1000ms for 5 minutes → ROLLBACK
  - Database connections >95% capacity → ROLLBACK
  - Pismo webhook failures >10 in 10 minutes → ROLLBACK
  - Transaction processing stopped (zero for 15 minutes) → ROLLBACK
  - Data sync failures >5 in 5 minutes → ROLLBACK
  - Security breach detected → IMMEDIATE ROLLBACK
Monitoring:
  - Cloud Monitoring dashboards
  - Error rate tracking
  - Response time tracking (P50, P95, P99)
  - Database connection monitoring
  - Business metrics (transaction volume, approval rate)
Outputs:
  - migration_docs/agents/rollout-plan.md
  - migration_docs/agents/rollout-monitoring-dashboard.md
  - migration_docs/agents/rollout-abort-procedures.md
"

### 8.3 Open Pull Requests
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Role: Release Manager
Objective: Open PRs for completed work per domain
Inputs:
  - migration_docs/work-queue.md (domains)
  - migration_docs/progress-tracker.json (completed work)
  - migration_docs/agents/rollout-plan.md
PR Template (per domain):
  Title: feat: migrate [domain] module ([X] functions)
  Body:
    ## Summary
    - Migrated [X] Firebase functions to NestJS
    - List of functions: [...]
    - Features implemented: [...]

    ## Changes
    - Controllers: [list]
    - Services: [list]
    - DTOs: [list]
    - Tests: [coverage %]

    ## Quality Gates
    - [ ] Gate S (Security): PASSED
    - [ ] Gate D (Swagger): PASSED
    - [ ] Gate E (Testing): PASSED
    - [ ] Coverage: [X]%

    ## Testing
    - Unit tests: [X] tests, [Y]% coverage
    - Integration tests: [X] tests
    - E2E tests: [X] tests
    - Parity validation: [X]% match

    ## Deployment Plan
    - Rollout: Staged (0.1% → 5% → 25% → 50% → 100%)
    - Duration: 13 days
    - Abort rules: [link to rollout-abort-procedures.md]

    ## Risks & Mitigations
    - Risk: [description]
      Mitigation: [strategy]

    ## Rollback Plan
    - [Detailed rollback steps]

    ## Attachments
    - FUNCTION_MAPPING.md delta
    - swagger.json
    - Prisma migrations
    - Test coverage report
    - ADR updates
Tool Usage:
  1. Read work-queue.md (get domains)
  2. Read progress-tracker.json (get completed functions per domain)
  3. For each domain with completed work:
     - Generate PR description from template
     - Collect artifacts (swagger.json, migrations, test reports)
     - Open PR
  4. Bash: gh pr create --title '...' --body '...' --base main
Success Criteria:
  - PR opened for each completed domain
  - All PRs have complete descriptions
  - All PRs have attached artifacts
  - All PRs reference rollout plan
Outputs:
  - PRs on GitHub (links in migration_docs/agents/pr-links.md)
  - migration_docs/agents/pr-templates.md
"

### 8.99 Phase 8 Checkpoint
Use Task tool with subagent_type="ignixxion-migration-supervisor"
Prompt:
"
Update Progress:
  - phase_8.status = 'complete'
  - completionPercentage: [final %]
Final Report:
  1. Total functions migrated: [X]/93
  2. Total domains completed: [Y]
  3. Coverage: [Z]%
  4. All gates: PASSED
  5. Deployment: Staged rollout in progress
Commit:
  - git add migration_docs/
  - git commit -m 'chore: migration Phase 8 complete - deployment underway

Summary:
- Functions migrated: [X]/93 ([Y]%)
- Domains complete: [list]
- All quality gates passed
- Staged rollout: 0.1% → 100% over 13 days

Next: Monitor rollout and address issues
'
  - git tag phase-8-complete
Outputs:
  - migration_docs/FINAL_REPORT.md
  - migration_docs/PROGRESS.md (final state)
  - migration_docs/agents/phase-8-completion-report.md
"

---

## WORKFLOW COMPLETION CONDITION

Stop when:
- All items in artifacts.json are marked 'completed' or explicitly 'deferred' with justification
- All PRs are merged or in production
- Staged rollout reached 100% traffic
- Firebase Functions decommissioned (or deprecated with warnings)
- Final report generated at migration_docs/FINAL_REPORT.md

---

## ERROR RECOVERY PROTOCOL

### Retry Logic (Applied to ALL Agent Calls)

```
MAX_RETRIES=3
RETRY_DELAY=30s

attempt=1
while [ $attempt -le $MAX_RETRIES ]; do
  Use Task tool with subagent_type="X" prompt="..."
  IF success:
    break
  ELSE:
    echo "⚠️  Agent call failed (attempt $attempt/$MAX_RETRIES)"
    echo "   Retrying in ${RETRY_DELAY}s..."
    sleep $RETRY_DELAY
    attempt=$((attempt + 1))
  FI
done

IF attempt > MAX_RETRIES:
  - Log failure to migration_docs/agents/failures.log
  - Update progress-tracker.json: phase_X.status = 'failed'
  - Prompt user: "Phase X step Y failed after 3 attempts.
    Options:
    1. Retry manually
    2. Skip step and continue (risky)
    3. Abort workflow
    Please choose:"
```

### Checkpointing (After Every Phase)

```
After Phase X.99:
1. Commit all outputs:
   git add migration_docs/ src/ test/ prisma/
   git commit -m "chore: complete Phase X - [description]"
   git tag phase-X-complete

2. Update progress tracker:
   - phase_X.status = 'complete'
   - phase_X.completedAt = [ISO timestamp]

3. Generate recovery command:
   echo "To resume from Phase X:" > migration_docs/RESUME.md
   echo "  git checkout feature/[domain]" >> migration_docs/RESUME.md
   echo "  git reset --hard phase-X-complete" >> migration_docs/RESUME.md
   echo "  Continue with Phase $((X + 1))" >> migration_docs/RESUME.md
```

### Validation & Re-prompting

```
IF agent output validation fails:
  1. Save invalid output:
     cp output.md migration_docs/agents/invalid/output-attempt-$attempt.md

  2. Generate fix prompt:
     "Previous output failed validation:
      Issues:
      - [SPECIFIC VALIDATION ERROR 1]
      - [SPECIFIC VALIDATION ERROR 2]

      Please regenerate with corrections.
      Reference invalid output at:
      migration_docs/agents/invalid/output-attempt-$attempt.md

      Expected output format:
      [SHOW VALID EXAMPLE]"

  3. Retry with enhanced prompt (max 2 retries)

  4. If still failing after 2 retries:
     - Escalate to user
     - Log to failures.log
     - Prompt user for manual intervention
```

### Rollback Procedures

#### Per-Phase Rollback

```
IF Phase X needs complete rollback:

1. Database Rollback (if schema changed):
   npx prisma migrate resolve --rolled-back [migration_name]
   # Reverts migration without applying down script

2. Code Rollback:
   git checkout feature/[domain]
   git reset --hard phase-$((X - 1))-complete
   git push --force-with-lease

3. Artifacts Rollback:
   git checkout HEAD~1 -- migration_docs/artifacts.json
   git checkout HEAD~1 -- migration_docs/progress-tracker.json
   git commit -m "revert: rollback Phase X"

4. Update Status:
   - Set progress-tracker.json: phase_X.status = 'rolled_back'
   - Set progress-tracker.json: phase_X.rollbackReason = '[reason]'
   - Log to migration_docs/rollback-log.md

5. Communicate:
   - Notify team of rollback
   - Document root cause
   - Plan remediation before retry
```

#### Full Workflow Rollback

```
IF entire migration needs rollback:

1. Traffic Rollback:
   # Switch 100% traffic back to Firebase Functions
   gcloud run services update-traffic nest-api \
     --to-revisions=PREVIOUS=100 \
     --region=us-central1

2. Deactivate Dual-Write:
   # Set environment variable
   export ENABLE_NESTJS_WRITES=false
   # This stops PostgreSQL writes, keeps only Firestore

3. Archive Work:
   git checkout -b archive/migration-attempt-$(date +%Y%m%d)
   git push origin archive/migration-attempt-$(date +%Y%m%d)

4. Document Lessons Learned:
   Write migration_docs/ROLLBACK_POSTMORTEM.md:
   - What failed
   - Root cause analysis
   - Fixes needed before retry
   - Estimated retry date
   - Changes to workflow
```

---

## APPENDIX A: Output Templates

### Template: specs-{domain}.md

```markdown
# {Domain} API Specifications

## Overview
- **Domain:** {domain}
- **Firebase Functions Migrated:** {count}
- **Priority:** CRITICAL/HIGH/MEDIUM/LOW
- **Feature Branch:** feature/{domain}-api
- **Dependencies:** [list if any]

## Endpoints

### {Function Name 1}

**Firebase Function:** `{firebaseFunctionName}`
**NestJS Endpoint:** `{METHOD} /api/v1/{resource}`
**Priority:** CRITICAL/HIGH/MEDIUM/LOW

#### Authentication
- **Auth Required:** Yes
- **Roles:** admin, fleet_manager, driver
- **Permissions:** {domain}:read, {domain}:write

#### Request

**Path Parameters:**
- `id` (UUID, required): Resource identifier

**Query Parameters:**
- `companyId` (UUID, optional): Filter by company (auto-applied for non-super_admin)
- `page` (int, default: 1): Page number
- `limit` (int, default: 20, max: 100): Items per page

**Headers:**
- `Authorization` (required): Bearer {firebase_token}
- `Idempotency-Key` (required for mutations): Unique request identifier

**Body (CreateDto):**
```typescript
{
  "field1": "value",
  "field2": 123,
  "nested": {
    "key": "value"
  }
}
```

**Validation Rules:**
- `field1`: IsString, MinLength(2), MaxLength(100), IsNotEmpty
- `field2`: IsNumber, Min(0), Max(1000)
- `nested`: ValidateNested, Type(() => NestedDto)

#### Response

**Success (201 Created):**
```json
{
  "status": "success",
  "data": {
    "id": "uuid-here",
    "field1": "value",
    "field2": 123,
    "createdAt": "2025-10-08T10:00:00Z",
    "updatedAt": "2025-10-08T10:00:00Z"
  },
  "metadata": {
    "timestamp": "2025-10-08T10:00:00Z"
  }
}
```

**Error (400 Bad Request):**
```json
{
  "status": "error",
  "message": "Validation failed",
  "code": "VALIDATION_ERROR",
  "statusCode": 400,
  "details": [
    {
      "field": "field1",
      "message": "field1 must be at least 2 characters"
    }
  ]
}
```

**Error (401 Unauthorized):**
```json
{
  "status": "error",
  "message": "Invalid authentication token",
  "code": "UNAUTHORIZED",
  "statusCode": 401
}
```

**Error (403 Forbidden):**
```json
{
  "status": "error",
  "message": "Insufficient permissions",
  "code": "FORBIDDEN",
  "statusCode": 403
}
```

**Error (500 Internal Server Error):**
```json
{
  "status": "error",
  "message": "Internal server error",
  "code": "INTERNAL_ERROR",
  "statusCode": 500
}
```

#### Idempotency
- Idempotency-Key header required for POST/PATCH/PUT
- Duplicate requests within 24h return cached response
- Cache key: `idempotency:{userId}:{Idempotency-Key}`

#### Rate Limits
- Authenticated users: 100 requests/minute
- Mutation endpoints: 20 requests/minute
- Exceeded: HTTP 429 Too Many Requests

#### Multi-Tenant Isolation
- All queries automatically filter by `user.companyId`
- super_admin can query across tenants (access logged)
- Cross-tenant access attempts return 403

#### Dual-Write Behavior
1. Write to PostgreSQL (source of truth)
2. Write to Firestore (backward compatibility)
3. If Firestore write fails:
   - Log error
   - Queue for retry (Bull)
   - Still return success (PostgreSQL succeeded)

#### Implementation Notes
- Service method: `{serviceName}.{methodName}()`
- Prisma model: `{PrismaModel}`
- Audit log: Record create/update/delete
- Soft delete: Set `deletedAt` timestamp

---

(Repeat for all endpoints in domain)
```

---

## APPENDIX B: Progress Tracker Schema

```json
{
  "version": "2.0",
  "lastUpdated": "2025-10-08T10:00:00Z",
  "totalFunctions": 93,
  "completedFunctions": 14,
  "completionPercentage": 15.05,
  "phases": {
    "phase_0": {
      "name": "Discovery & Planning",
      "status": "complete",
      "startedAt": "2025-09-01T09:00:00Z",
      "completedAt": "2025-09-05T17:00:00Z"
    },
    "phase_1": {
      "name": "Pismo Integration Foundation",
      "status": "complete",
      "startedAt": "2025-09-10T09:00:00Z",
      "completedAt": "2025-10-05T17:00:00Z",
      "functionsCompleted": 2
    },
    "phase_2": {
      "name": "Database Schema Optimization",
      "status": "complete",
      "startedAt": "2025-10-06T09:00:00Z",
      "completedAt": "2025-10-12T17:00:00Z"
    },
    "phase_3": {
      "name": "Card Operations",
      "status": "in_progress",
      "startedAt": "2025-10-13T09:00:00Z",
      "functionsCompleted": 12
    }
  },
  "domains": {
    "pismo": {
      "total": 44,
      "completed": 14,
      "inProgress": 0,
      "priority": "CRITICAL",
      "branch": "feature/pismo-integration"
    },
    "companies": {
      "total": 5,
      "completed": 0,
      "inProgress": 0,
      "priority": "HIGH",
      "branch": "feature/companies-api"
    },
    "drivers": {
      "total": 8,
      "completed": 0,
      "inProgress": 0,
      "priority": "HIGH",
      "branch": "feature/drivers-api"
    }
  },
  "blockers": [
    {
      "id": "BLOCKER-2",
      "description": "Business Logic Modules (0% Complete)",
      "severity": "CRITICAL",
      "status": "in_progress",
      "eta": "2025-11-30"
    }
  ],
  "gates": {
    "gate_s": {
      "name": "Security Validation",
      "status": "passed",
      "passedAt": "2025-10-20T17:00:00Z"
    },
    "gate_d": {
      "name": "Swagger Coverage",
      "status": "pending"
    },
    "gate_e": {
      "name": "Testing & Parity",
      "status": "pending"
    }
  }
}
```

---

**Workflow Version:** 2.0
**Created:** 2025-10-08
**Last Updated:** 2025-10-08
**Author:** Claude Code + Human Review
**Status:** PRODUCTION READY (pending team review)
