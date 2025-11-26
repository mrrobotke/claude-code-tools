---
model: inherit
thinking: true
---

# React Native Pages Migration Workflow

**Purpose:** Migrate all end-user pages from Ionic/Angular to React Native following Brad Frost's Atomic Design methodology

**Target:** Close GitHub issue #19 and all 9 sub-issues by implementing ~30 pages with full UX parity

**Working Directory:** `VisaGoRN/` subdirectory

---

## Preconditions

- Brad Frost Atomic Design structure established: atoms → molecules → organisms → templates → pages
- Existing UI components in `src/ui/atoms/`, `src/ui/molecules/`, `src/ui/organisms/`
- Templates exist: `AuthLayout`, `DriverPortalLayout`, `AdminTabLayout`
- Navigation setup: React Navigation 7
- State management: Redux Toolkit
- Theme system: `useAppTheme()` hook available
- TypeScript 5.9+ with strict mode
- Path aliases configured (`@ui/*`, `@features/*`, etc.)

---

## Workflow Overview

**Execution Strategy:**
- 3 phases execute sequentially
- Within each phase, agents run in **parallel**
- Each agent owns one GitHub sub-issue
- Agents automatically close issues upon successful completion
- Quality gates enforce standards between phases

**Atomic Design Compliance:**
- All pages must use existing atoms/molecules/organisms
- No inline styles (use StyleSheet + theme)
- Follow component structure: `[Name].tsx`, `[Name].styles.ts`, `[Name].types.ts`, `index.ts`
- Leverage templates for layout consistency

---

## Phase 0: Pre-Flight Validation

### 0.1 Environment Check
Use Task tool with subagent_type="mobile-developer"
Prompt:
"
Role: Mobile DevOps Engineer
Objective: Validate React Native environment and dependencies for pages migration

Validation Checklist:
  1. Working directory: VisaGoRN/
  2. Check Node.js version >= 20.19
  3. Check yarn installation
  4. Verify .env.development, .env.test, .env.production exist
  5. Run yarn install --immutable
  6. Check atomic design structure exists:
     - src/ui/atoms/
     - src/ui/molecules/
     - src/ui/organisms/
     - src/ui/templates/
     - src/ui/pages/
  7. Verify templates exist:
     - AuthLayout
     - DriverPortalLayout
     - AdminTabLayout
  8. Check navigation setup (React Navigation installed)
  9. Check state management (Redux Toolkit installed)
  10. Check theme system (useAppTheme hook exists)

Tool Usage:
  1. Bash: cd VisaGoRN && node --version
  2. Bash: cd VisaGoRN && yarn --version
  3. Bash: cd VisaGoRN && ls .env.*
  4. Glob: VisaGoRN/src/ui/atoms/**/*.tsx
  5. Glob: VisaGoRN/src/ui/templates/**/*.tsx
  6. Read: VisaGoRN/package.json (check dependencies)
  7. Bash: cd VisaGoRN && yarn typecheck (verify no existing errors)

Success Criteria:
  - All 10 checks pass
  - No TypeScript errors in existing codebase
  - Environment files present

Outputs:
  - VisaGoRN/migration_docs/pre-flight-validation.md (PASS/FAIL report)
"

GATE ENFORCEMENT:
IF pre-flight-validation.md status == 'FAIL':
  - STOP workflow
  - Display failures
  - Require fixes before proceeding
ELSE:
  - Log: 'Pre-flight validation PASSED'
  - Proceed to Phase 1

---

## Phase 1: Foundation (Parallel Execution)

**Priority:** CRITICAL (Blocks all other pages)
**Effort:** 3-4 days
**Sub-Issues:** 2
**Agents:** 2 running in parallel

### 1.1 Authentication Pages (Issue #20)
Use Task tool with subagent_type="mobile-developer"
Prompt:
"
Role: React Native Mobile Developer
Objective: Implement all authentication pages per Brad Frost Atomic Design methodology

GitHub Issue: #20 - Create Authentication Pages
Working Directory: VisaGoRN/

Pages to Implement:
  1. Core Authentication:
     - LoginPage
     - RegisterPage
     - BiometricPage

  2. Password Management:
     - VerifyOtpPage
     - RequestResetPasswordPage
     - ResetPasswordPage
     - RequestEmailVerificationPage

  3. Registration Flow:
     - RegisterUserInfoPage
     - RegisterDriverPage
     - RegisterInvitePage
     - RegisterCompanyPage
     - RegisterVehiclesPage
     - RegisterConfirmOtpPage

Atomic Design Rules:
  - Use existing atoms from src/ui/atoms/ (Button, Input, Text, etc.)
  - Use existing molecules from src/ui/molecules/
  - Compose organisms if needed (FormGroup, AuthCard)
  - Use AuthLayout template for consistent structure
  - Follow component pattern:
    * [PageName]/[PageName].tsx
    * [PageName]/[PageName].styles.ts
    * [PageName]/[PageName].types.ts
    * [PageName]/index.ts

Technical Requirements:
  - Import theme: import { useAppTheme } from '@ui/theme/ThemeProvider';
  - Use path aliases: import Button from '@ui/atoms/Button';
  - StyleSheet only (no inline styles)
  - TypeScript strict types (no 'any')
  - Form validation with react-hook-form or Formik
  - Firebase Auth integration (existing)
  - Redux state integration for auth flow
  - Navigation types defined in @navigation/*
  - Accessibility: proper labels, keyboard navigation
  - Error handling and loading states

Example Structure:
  src/ui/pages/auth/
  ├── LoginPage/
  │   ├── LoginPage.tsx
  │   ├── LoginPage.styles.ts
  │   ├── LoginPage.types.ts
  │   └── index.ts
  ├── RegisterPage/
  │   └── ...
  └── ...

Tool Usage:
  1. Read: VisaGoRN/src/ui/atoms/ (identify available components)
  2. Read: VisaGoRN/src/ui/templates/AuthLayout/ (understand layout)
  3. Read: VisaGoRN/src/navigation/ (understand navigation setup)
  4. For each page:
     - Write [PageName].tsx
     - Write [PageName].styles.ts
     - Write [PageName].types.ts
     - Write index.ts
  5. Edit: VisaGoRN/src/navigation/AuthNavigator.tsx (add routes)
  6. Write: VisaGoRN/src/ui/pages/auth/index.ts (barrel export)
  7. Bash: cd VisaGoRN && yarn typecheck
  8. Bash: cd VisaGoRN && yarn lint --fix

Testing Requirements:
  - Basic smoke tests for each page (renders without crash)
  - Form validation tests
  - Navigation flow tests
  - At least 70% test coverage

Success Criteria:
  - All 13 auth pages implemented
  - Follow atomic design structure
  - TypeScript compiles with no errors
  - Linting passes
  - Tests pass
  - Navigation wired correctly
  - Integration with Firebase Auth works

Issue Closure:
  - After success, comment on issue #20 with completion summary
  - Bash: gh issue close 20 --repo Ignixxion/Evermile.DM.React.Mobile --comment 'Completed: All authentication pages implemented following Atomic Design. Tests passing. Ready for review.'

Outputs:
  - src/ui/pages/auth/** (all auth pages)
  - migration_docs/agents/auth-pages-implementation.md (completion report)
"

### 1.2 Driver Portal Shell & Navigation (Issue #28)
Use Task tool with subagent_type="mobile-developer"
Prompt:
"
Role: React Native Mobile Developer
Objective: Implement driver portal shell with bottom tab navigation per Atomic Design

GitHub Issue: #28 - Driver Portal Shell & Navigation
Working Directory: VisaGoRN/

Pages to Implement:
  - DriverPortalShellPage (main container with tabs)

Shell Features:
  1. Bottom tab navigation (React Navigation Bottom Tabs)
  2. Tab items: Home, Card, Transactions, Profile
  3. Vehicle assignment flow:
     - No vehicle assigned state
     - Vehicle selection/assignment
     - Vehicle assigned state
  4. Trip controls:
     - Start trip
     - Stop trip modal
  5. Status indicators and notifications

Atomic Design Rules:
  - Use DriverPortalLayout template
  - Compose organisms: NavigationTabs, VehicleSelector, TripControls
  - Use atoms/molecules for tab items and buttons
  - Follow standard component structure

Technical Requirements:
  - React Navigation Bottom Tabs
  - Redux state: vehicle assignment, trip status
  - Deep linking support (ignixxionAus://driver/*)
  - Background location tracking integration
  - Push notification handling
  - Proper tab icon states (active/inactive)
  - Accessibility labels for tab navigation

Component Structure:
  src/ui/pages/driver-portal/
  ├── DriverPortalShellPage/
  │   ├── DriverPortalShellPage.tsx
  │   ├── DriverPortalShellPage.styles.ts
  │   ├── DriverPortalShellPage.types.ts
  │   └── index.ts
  └── index.ts

Organisms to Compose:
  - NavigationTabs (if doesn't exist, create in src/ui/organisms/)
  - VehicleAssignmentCard
  - TripControlsBar
  - DriverStatusHeader

Tool Usage:
  1. Read: src/ui/templates/DriverPortalLayout/
  2. Read: src/ui/organisms/ (check existing organisms)
  3. Glob: src/ui/atoms/**/*.tsx (identify available components)
  4. Write: DriverPortalShellPage.tsx
  5. Write: DriverPortalShellPage.styles.ts
  6. Write: DriverPortalShellPage.types.ts
  7. Write: index.ts
  8. Edit: src/navigation/DriverNavigator.tsx (set up tab navigation)
  9. Write tests: DriverPortalShellPage.test.tsx
  10. Bash: yarn typecheck && yarn lint --fix

Testing Requirements:
  - Tab navigation works
  - Vehicle assignment flow tested
  - Trip start/stop tested
  - State changes reflected in UI

Success Criteria:
  - Shell page implemented with tab navigation
  - All 3 vehicle states rendered correctly
  - Trip controls functional
  - Navigation wired to other driver pages
  - Follows Atomic Design structure
  - TypeScript + linting pass
  - Tests pass

Issue Closure:
  - Bash: gh issue close 28 --repo Ignixxion/Evermile.DM.React.Mobile --comment 'Completed: Driver portal shell with tab navigation implemented. Vehicle assignment flow and trip controls functional. Ready for review.'

Outputs:
  - src/ui/pages/driver-portal/DriverPortalShellPage/**
  - src/ui/organisms/NavigationTabs/** (if created)
  - migration_docs/agents/driver-shell-implementation.md
"

### 1.99 Phase 1 Checkpoint
After both agents complete (parallel execution):

Validation:
  1. Check issue #20 closed
  2. Check issue #28 closed
  3. Run: cd VisaGoRN && yarn typecheck (must pass)
  4. Run: cd VisaGoRN && yarn lint (must pass)
  5. Run: cd VisaGoRN && yarn test (must pass)
  6. Verify navigation: auth → driver portal works

GATE ENFORCEMENT:
IF any validation fails:
  - STOP workflow
  - Report failures
  - Require fixes
ELSE:
  - Log: 'Phase 1 COMPLETE - Foundation ready'
  - Proceed to Phase 2

---

## Phase 2: Core Features (Parallel Execution)

**Priority:** HIGH
**Effort:** 5-7 days
**Sub-Issues:** 5
**Agents:** 5 running in parallel

### 2.1 Card Tab (Issue #32)
Use Task tool with subagent_type="mobile-developer"
Prompt:
"
Role: React Native Mobile Developer
Objective: Implement Card tab with two states (no card / card assigned)

GitHub Issue: #32 - Driver portal Card tab
Working Directory: VisaGoRN/

Pages/Components:
  - CardTabPage (main tab page)
  - CardNoAssignedState (organism)
  - CardAssignedState (organism)
  - CardDetailsCard (organism)

States to Implement:
  1. No Card Assigned:
     - Empty state message
     - Request card button
     - Contact admin instructions

  2. Card Assigned:
     - Card visual representation
     - Card number (masked)
     - Card status (active/blocked/frozen)
     - Available balance
     - Recent transactions summary
     - Card controls: freeze/unfreeze, report lost

Atomic Design:
  - Page: CardTabPage
  - Organisms: CardNoAssignedState, CardAssignedState, CardDetailsCard
  - Molecules: CardStatusBadge, CardControlButton, TransactionSummaryCard
  - Atoms: Button, Text, Icon, Card (container)

Technical Requirements:
  - Redux state: card info, status, balance
  - Pismo API integration (existing services)
  - Real-time balance updates
  - Card controls with confirmation modals
  - Error handling for API calls
  - Loading skeletons while fetching data

Tool Usage:
  1. Read: src/data/repositories/CardRepository.ts (understand API)
  2. Read: src/state/slices/cardSlice.ts (Redux state)
  3. Write: CardTabPage/**
  4. Write: src/ui/organisms/CardNoAssignedState/**
  5. Write: src/ui/organisms/CardAssignedState/**
  6. Edit: src/navigation/DriverNavigator.tsx (add Card tab)
  7. Bash: yarn typecheck && yarn lint --fix && yarn test

Success Criteria:
  - Both states render correctly
  - Card controls functional
  - API integration works
  - Follows Atomic Design
  - Tests pass

Issue Closure:
  - Bash: gh issue close 32 --repo Ignixxion/Evermile.DM.React.Mobile --comment 'Completed: Card tab with both states implemented. API integration working. Ready for review.'

Outputs:
  - src/ui/pages/driver-portal/CardTabPage/**
  - src/ui/organisms/Card*/**
  - migration_docs/agents/card-tab-implementation.md
"

### 2.2 Transactions Tab (Issue #33)
Use Task tool with subagent_type="mobile-developer"
Prompt:
"
Role: React Native Mobile Developer
Objective: Implement Transactions tab with list and filtering

GitHub Issue: #33 - Driver Portal Transactions Tab
Working Directory: VisaGoRN/

Pages/Components:
  - TransactionsTabPage
  - TransactionsList (organism - may already exist)
  - TransactionFilterBar (organism)
  - TransactionCard (molecule)

Features:
  1. Transaction list:
     - Date descending order
     - Grouped by date
     - Infinite scroll / pagination
     - Pull to refresh

  2. Transaction details:
     - Merchant name
     - Amount
     - Date/time
     - Category (fuel, parking, toll, etc.)
     - Status (approved, pending, declined)

  3. Filtering:
     - Date range picker
     - Category filter
     - Status filter
     - Search by merchant

Atomic Design:
  - Page: TransactionsTabPage
  - Organisms: TransactionsList, TransactionFilterBar
  - Molecules: TransactionCard, DateRangePicker, CategoryFilter
  - Atoms: Text, Icon, Badge, Touchable

Technical Requirements:
  - Redux state: transactions list, filters
  - Pagination with FlatList
  - Date grouping logic
  - Filter state management
  - Empty state when no transactions
  - Error handling for API failures

Tool Usage:
  1. Read: src/ui/organisms/TransactionsList/ (if exists)
  2. Read: src/data/repositories/TransactionRepository.ts
  3. Write: TransactionsTabPage/**
  4. Write/Edit: src/ui/organisms/TransactionsList/** (if needed)
  5. Write: src/ui/organisms/TransactionFilterBar/**
  6. Write: src/ui/molecules/TransactionCard/**
  7. Edit: src/navigation/DriverNavigator.tsx
  8. Bash: yarn typecheck && yarn lint --fix && yarn test

Success Criteria:
  - Transaction list renders with proper grouping
  - Pagination works smoothly
  - Filters work correctly
  - Pull to refresh functional
  - Follows Atomic Design
  - Tests pass

Issue Closure:
  - Bash: gh issue close 33 --repo Ignixxion/Evermile.DM.React.Mobile --comment 'Completed: Transactions tab with filtering and pagination. Tests passing. Ready for review.'

Outputs:
  - src/ui/pages/driver-portal/TransactionsTabPage/**
  - src/ui/organisms/TransactionFilterBar/**
  - migration_docs/agents/transactions-tab-implementation.md
"

### 2.3 Profile Page (Issue #24)
Use Task tool with subagent_type="mobile-developer"
Prompt:
"
Role: React Native Mobile Developer
Objective: Implement user profile management page

GitHub Issue: #24 - Profile Page
Working Directory: VisaGoRN/

Pages/Components:
  - ProfilePage
  - ProfileHeader (organism)
  - ProfileEditForm (organism)
  - ProfileMenuItem (molecule)

Features:
  1. Profile View:
     - User avatar/photo
     - Full name
     - Email
     - Phone number
     - Company name
     - Role
     - Driver license info (if driver)

  2. Profile Edit:
     - Edit personal info modal/screen
     - Photo upload (camera or gallery)
     - Form validation
     - Save changes

  3. Settings Menu:
     - Language preference
     - Notifications settings
     - Biometric settings
     - Theme (light/dark)
     - Logout

Atomic Design:
  - Page: ProfilePage
  - Organisms: ProfileHeader, ProfileEditForm, SettingsMenu
  - Molecules: ProfileMenuItem, AvatarUploader, SettingToggle
  - Atoms: Avatar, Text, Button, Switch

Technical Requirements:
  - Redux state: user profile
  - Camera integration (react-native-vision-camera)
  - Image picker integration
  - Form validation
  - API integration for profile update
  - Biometric settings (react-native-biometrics)
  - Logout flow (clear Redux + navigate to auth)

Tool Usage:
  1. Read: src/state/slices/userSlice.ts
  2. Read: src/data/repositories/UserRepository.ts
  3. Write: ProfilePage/**
  4. Write: src/ui/organisms/ProfileHeader/**
  5. Write: src/ui/organisms/ProfileEditForm/**
  6. Write: src/ui/molecules/ProfileMenuItem/**
  7. Edit: src/navigation/DriverNavigator.tsx
  8. Bash: yarn typecheck && yarn lint --fix && yarn test

Success Criteria:
  - Profile displays user info correctly
  - Edit flow works with validation
  - Photo upload functional
  - Settings save properly
  - Logout works correctly
  - Follows Atomic Design
  - Tests pass

Issue Closure:
  - Bash: gh issue close 24 --repo Ignixxion/Evermile.DM.React.Mobile --comment 'Completed: Profile page with edit functionality and settings. Camera integration working. Ready for review.'

Outputs:
  - src/ui/pages/driver-portal/ProfilePage/**
  - src/ui/organisms/Profile*/**
  - migration_docs/agents/profile-page-implementation.md
"

### 2.4 Trip and Fuel Pages (Issue #29)
Use Task tool with subagent_type="mobile-developer"
Prompt:
"
Role: React Native Mobile Developer
Objective: Implement trip management and fuel tracking pages

GitHub Issue: #29 - Trip and Fuel
Working Directory: VisaGoRN/

Pages to Implement:
  1. TripManagerPage
  2. FuelPage
  3. FuelDetailsPage

Trip Manager Features:
  - Current trip status
  - Start trip button
  - Stop trip confirmation
  - Trip history list
  - Trip details (route, duration, distance)
  - GPS tracking integration

Fuel Features:
  - Fuel capture form
  - Receipt photo upload
  - Fuel history list
  - Fuel details: volume, cost, odometer, location
  - Barcode scanning for receipts

Atomic Design:
  - Pages: TripManagerPage, FuelPage, FuelDetailsPage
  - Organisms: TripCard, FuelCaptureForm, FuelHistoryList, ReceiptUploader
  - Molecules: TripStatusBadge, FuelCard, ReceiptPreview
  - Atoms: Button, Input, Image, Text

Technical Requirements:
  - Background location tracking (react-native-background-geolocation)
  - Camera integration for receipts
  - Barcode scanning (@react-native-ml-kit/barcode-scanning)
  - Form validation for fuel capture
  - Google Maps integration for location
  - Redux state: trips, fuel entries

Tool Usage:
  1. Read: src/native/LocationTracking.ts
  2. Read: src/data/repositories/TripRepository.ts
  3. Read: src/data/repositories/FuelRepository.ts
  4. Write: TripManagerPage/**
  5. Write: FuelPage/**
  6. Write: FuelDetailsPage/**
  7. Write: src/ui/organisms/TripCard/**
  8. Write: src/ui/organisms/FuelCaptureForm/**
  9. Edit: src/navigation/DriverNavigator.tsx
  10. Bash: yarn typecheck && yarn lint --fix && yarn test

Success Criteria:
  - Trip management functional
  - Fuel capture with photo works
  - Barcode scanning works
  - Location tracking integrated
  - Follows Atomic Design
  - Tests pass

Issue Closure:
  - Bash: gh issue close 29 --repo Ignixxion/Evermile.DM.React.Mobile --comment 'Completed: Trip manager and fuel pages. GPS tracking and camera integration working. Ready for review.'

Outputs:
  - src/ui/pages/driver-portal/Trip*/**
  - src/ui/pages/driver-portal/Fuel*/**
  - migration_docs/agents/trip-fuel-implementation.md
"

### 2.5 Maintenance and Meals Pages (Issue #30)
Use Task tool with subagent_type="mobile-developer"
Prompt:
"
Role: React Native Mobile Developer
Objective: Implement maintenance tracking and meal details pages

GitHub Issue: #30 - Maintenance and Meals
Working Directory: VisaGoRN/

Pages to Implement:
  1. MaintenancePage
  2. ServiceDetailsPage
  3. MealDetailsPage

Maintenance Features:
  - Maintenance history list
  - Service types: oil change, tire rotation, inspection, repair
  - Service details: date, cost, odometer, notes
  - Attachment upload (photos, invoices)
  - Service reminders/scheduling

Meal Features:
  - Meal capture form
  - Receipt photo upload
  - Meal details: type, cost, location, date
  - Meal history list
  - Category selection

Atomic Design:
  - Pages: MaintenancePage, ServiceDetailsPage, MealDetailsPage
  - Organisms: MaintenanceList, ServiceForm, MealCaptureForm
  - Molecules: MaintenanceCard, MealCard, AttachmentUploader
  - Atoms: Button, Input, Image, Text, DatePicker

Technical Requirements:
  - Camera integration for receipts/photos
  - Document picker for invoices
  - Form validation
  - Redux state: maintenance records, meals
  - Date/time pickers
  - Location capture (optional)

Tool Usage:
  1. Read: src/data/repositories/MaintenanceRepository.ts
  2. Read: src/data/repositories/MealRepository.ts
  3. Write: MaintenancePage/**
  4. Write: ServiceDetailsPage/**
  5. Write: MealDetailsPage/**
  6. Write: src/ui/organisms/MaintenanceList/**
  7. Write: src/ui/organisms/ServiceForm/**
  8. Write: src/ui/organisms/MealCaptureForm/**
  9. Edit: src/navigation/DriverNavigator.tsx
  10. Bash: yarn typecheck && yarn lint --fix && yarn test

Success Criteria:
  - Maintenance tracking works
  - Service details captured correctly
  - Meal capture with receipt works
  - Photo/document upload functional
  - Follows Atomic Design
  - Tests pass

Issue Closure:
  - Bash: gh issue close 30 --repo Ignixxion/Evermile.DM.React.Mobile --comment 'Completed: Maintenance and meal pages with photo/document upload. Tests passing. Ready for review.'

Outputs:
  - src/ui/pages/driver-portal/Maintenance*/**
  - src/ui/pages/driver-portal/Meal*/**
  - migration_docs/agents/maintenance-meals-implementation.md
"

### 2.99 Phase 2 Checkpoint
After all 5 agents complete (parallel execution):

Validation:
  1. Check issues #32, #33, #24, #29, #30 closed
  2. Run: cd VisaGoRN && yarn typecheck (must pass)
  3. Run: cd VisaGoRN && yarn lint (must pass)
  4. Run: cd VisaGoRN && yarn test (must pass)
  5. Run: cd VisaGoRN && yarn test:coverage (must be >= 70%)
  6. Verify all tabs render in driver portal shell
  7. Test navigation between all pages

GATE ENFORCEMENT:
IF any validation fails:
  - STOP workflow
  - Report failures
  - Require fixes
ELSE:
  - Log: 'Phase 2 COMPLETE - Core features ready'
  - Proceed to Phase 3

---

## Phase 3: Service Pages (Single Agent)

**Priority:** MEDIUM
**Effort:** 4-5 days
**Sub-Issues:** 1
**Agents:** 1

### 3.1 Driver Services Pages (Issue #22)
Use Task tool with subagent_type="mobile-developer"
Prompt:
"
Role: React Native Mobile Developer
Objective: Implement various driver service pages

GitHub Issue: #22 - Driver Services Pages
Working Directory: VisaGoRN/

Pages to Implement:
  1. ParkingPage
  2. TollPage
  3. PaymentConfirmPage
  4. PaymentPage
  5. EVPage (Electric Vehicle charging)
  6. CarWashPage
  7. AccommodationPage

Common Features:
  - Service capture forms
  - Receipt/invoice photo upload
  - Location capture
  - Cost tracking
  - Date/time capture
  - Payment confirmation flow
  - History/list view

Atomic Design:
  - Pages: [Service]Page (7 pages)
  - Organisms: ServiceCaptureForm, ServiceHistoryList, ReceiptUploader
  - Molecules: ServiceCard, LocationPicker, PaymentSummary
  - Atoms: Button, Input, Image, Text, DatePicker

Technical Requirements:
  - Reuse organisms from Phase 2 where possible
  - Camera integration for receipts
  - Location services integration
  - Form validation
  - Redux state: service records
  - Payment integration (Stripe) for PaymentPage
  - Google Pay / Apple Pay for PaymentConfirmPage

Tool Usage:
  1. Read: src/ui/organisms/ServiceCaptureForm/ (if exists from Phase 2)
  2. Read: src/data/repositories/*Repository.ts
  3. For each page:
     - Write [ServiceName]Page/**
  4. Write: src/ui/organisms/PaymentSummary/** (if needed)
  5. Edit: src/navigation/DriverNavigator.tsx (add all routes)
  6. Bash: yarn typecheck && yarn lint --fix && yarn test

Success Criteria:
  - All 7 service pages implemented
  - Forms work with validation
  - Photo upload functional
  - Payment flows work
  - Follows Atomic Design
  - Reuses organisms from Phase 2
  - Tests pass (>70% coverage)

Issue Closure:
  - Bash: gh issue close 22 --repo Ignixxion/Evermile.DM.React.Mobile --comment 'Completed: All 7 driver service pages implemented. Payment integration working. Tests passing. Ready for review.'

Outputs:
  - src/ui/pages/driver-portal/Parking*/**
  - src/ui/pages/driver-portal/Toll*/**
  - src/ui/pages/driver-portal/Payment*/**
  - src/ui/pages/driver-portal/EV*/**
  - src/ui/pages/driver-portal/CarWash*/**
  - src/ui/pages/driver-portal/Accommodation*/**
  - migration_docs/agents/service-pages-implementation.md
"

### 3.99 Phase 3 Checkpoint
After agent completes:

Validation:
  1. Check issue #22 closed
  2. Run: cd VisaGoRN && yarn typecheck (must pass)
  3. Run: cd VisaGoRN && yarn lint (must pass)
  4. Run: cd VisaGoRN && yarn test (must pass)
  5. Run: cd VisaGoRN && yarn test:coverage (must be >= 70%)
  6. Verify all service pages accessible via navigation
  7. Test payment flows

GATE ENFORCEMENT:
IF any validation fails:
  - STOP workflow
  - Report failures
  - Require fixes
ELSE:
  - Log: 'Phase 3 COMPLETE - Service pages ready'
  - Proceed to Phase 4 (Final Validation)

---

## Phase 4: Final Validation & Issue Closure

### 4.1 Comprehensive Testing
Use Task tool with subagent_type="mobile-developer"
Prompt:
"
Role: QA Engineer
Objective: Run comprehensive test suite and validation

Validation Steps:
  1. TypeScript compilation:
     - Bash: cd VisaGoRN && yarn typecheck
     - Must pass with 0 errors

  2. Linting:
     - Bash: cd VisaGoRN && yarn lint
     - Must pass with 0 errors

  3. Unit tests:
     - Bash: cd VisaGoRN && yarn test
     - All tests must pass

  4. Test coverage:
     - Bash: cd VisaGoRN && yarn test:coverage
     - Must be >= 70% for all metrics

  5. Component count verification:
     - Glob: src/ui/pages/auth/**/*.tsx (count auth pages)
     - Glob: src/ui/pages/driver-portal/**/*.tsx (count driver pages)
     - Total should be ~30 pages

  6. Atomic Design compliance:
     - Grep: pattern='StyleSheet.create' (all pages must use StyleSheet)
     - Grep: pattern='useAppTheme' (all pages must use theme)
     - Grep: pattern='style={{' (no inline styles allowed)

  7. Navigation verification:
     - Read: src/navigation/AuthNavigator.tsx (check routes)
     - Read: src/navigation/DriverNavigator.tsx (check routes)
     - All pages must be routed

  8. Build test:
     - Bash: cd VisaGoRN && yarn build:android (test Android build)
     - Must complete successfully

Success Criteria:
  - All 8 validation steps pass
  - No TypeScript errors
  - No linting errors
  - All tests pass
  - Coverage >= 70%
  - ~30 pages implemented
  - No inline styles
  - All pages routed

Outputs:
  - migration_docs/final-validation-report.md (detailed report)
"

### 4.2 Close Parent Issue
After validation passes:

Use Task tool with subagent_type="mobile-developer"
Prompt:
"
Role: Project Manager
Objective: Close parent issue #19 with comprehensive summary

Steps:
  1. Read: migration_docs/agents/*.md (all completion reports)
  2. Count total pages implemented
  3. Verify all sub-issues closed:
     - Issue #20 (Auth pages)
     - Issue #21 (Core Driver Portal) - if exists
     - Issue #22 (Service pages)
     - Issue #24 (Profile)
     - Issue #28 (Shell)
     - Issue #29 (Trip/Fuel)
     - Issue #30 (Maintenance/Meals)
     - Issue #32 (Card tab)
     - Issue #33 (Transactions tab)
  4. Generate summary comment
  5. Close parent issue

Summary Comment Template:
  '
  # Pages Migration Complete

  ## Summary
  Successfully migrated all end-user pages from Ionic/Angular to React Native following Brad Frost Atomic Design methodology.

  ## Pages Implemented
  - Authentication: 13 pages
  - Driver Portal Shell: 1 page
  - Core Features: 8 pages
  - Service Pages: 7 pages
  - **Total: ~30 pages**

  ## Sub-Issues Closed
  - #20 Authentication Pages
  - #22 Driver Services Pages
  - #24 Profile Page
  - #28 Driver Portal Shell
  - #29 Trip and Fuel
  - #30 Maintenance and Meals
  - #32 Card Tab
  - #33 Transactions Tab

  ## Quality Metrics
  - TypeScript: 0 errors
  - Linting: 0 errors
  - Tests: All passing
  - Coverage: 75%+
  - Atomic Design: 100% compliant

  ## Technical Details
  - Followed Brad Frost Atomic Design (atoms → molecules → organisms → templates → pages)
  - No inline styles (100% StyleSheet)
  - Path aliases used consistently
  - Theme system integrated
  - Navigation fully wired
  - State management (Redux) integrated
  - Platform capabilities integrated (camera, location, notifications)

  ## Next Steps
  - Admin portal pages (if applicable)
  - E2E testing
  - Performance optimization
  - App store submission prep

  Ready for review and QA testing.
  '

Issue Closure:
  - Bash: gh issue close 19 --repo Ignixxion/Evermile.DM.React.Mobile --comment '[summary]'

Outputs:
  - migration_docs/pages-migration-complete.md (final report)
"

---

## Error Recovery Protocol

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
    echo "Agent call failed (attempt $attempt/$MAX_RETRIES)"
    echo "Retrying in ${RETRY_DELAY}s..."
    sleep $RETRY_DELAY
    attempt=$((attempt + 1))
  FI
done

IF attempt > MAX_RETRIES:
  - Log failure to migration_docs/failures.log
  - Prompt user: "Phase X step Y failed after 3 attempts.
    Options:
    1. Retry manually
    2. Skip step (risky)
    3. Abort workflow
    Please choose:"
```

### Phase Rollback

```
IF Phase X fails validation:
  1. Identify failed sub-issue
  2. Roll back changes for that sub-issue only (git)
  3. Re-run agent for that sub-issue
  4. Do not block other completed sub-issues
  5. Retry validation
```

---

## Workflow Completion Condition

**Complete when:**
- All 9 sub-issues closed
- Parent issue #19 closed
- ~30 pages implemented
- All validation gates passed
- Final report generated

---

## Success Metrics

**Quantitative:**
- Pages implemented: ~30
- Sub-issues closed: 9/9 (100%)
- Test coverage: >= 70%
- TypeScript errors: 0
- Linting errors: 0
- Build success rate: 100%

**Qualitative:**
- Atomic Design compliance: 100%
- UX parity with Ionic app: 100%
- Navigation flows: Complete
- State management: Integrated
- Platform capabilities: Integrated
- Code quality: High (no inline styles, typed interfaces, tests)

---

**Workflow Version:** 1.0
**Created:** 2025-01-10
**Author:** Claude Code + Human Review
**Status:** READY FOR EXECUTION

** Important **
- To save time, the workflow should use the Task tool to run the agents in parallel and not syncronously as long as the phases are not blocking each other.