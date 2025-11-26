---
model: claude-opus-4-1
---

Perform a comprehensive **React Native Mobile Application** review using multiple specialized agents with explicit Task tool invocations. **All agents are launched in parallel in a single invocation** for maximum efficiency. Each stage produces detailed, structured markdown reports saved to the `code_review/` directory.

[Extended thinking: This workflow performs a thorough multi-perspective review specifically tailored for React Native mobile apps with Expo, TypeScript, Redux Toolkit, and Firebase. Each agent examines different mobile-specific aspects and Generate/updates standardized markdown reports with consistent formatting. All outputs are saved to code_review/ folder for easy organization and reference. CRITICAL: All review agents (stages 1-13) must be spawned simultaneously in a single parallel Task tool invocation - they are fully independent and should NOT wait for each other.]

---

## 📁 Output Directory Structure

All review outputs will be saved to: `code_review/`

```
code_review/
├── 01_mobile_code_quality.md
├── 02_typescript_review.md
├── 03_architecture_review.md
├── 04_mobile_security_audit.md
├── 05_frontend_security_review.md
├── 06_performance_analysis.md
├── 07_ui_ux_review.md
├── 08_visual_validation.md
├── 09_redux_state_review.md
├── 10_testing_strategy.md
├── 11_security_compliance.md
├── 12_devops_build_config.md
├── 13_tdd_compliance.md (optional)
└── 00_consolidated_report.md (final summary)
```

---

## Standard Markdown Formatting Guidelines

**All output files MUST follow this consistent formatting:**

### Document Structure
```markdown
# [Stage Number]. [Review Area Title]

**Review Date**: YYYY-MM-DD
**Reviewed Files**: [List of files/paths]
**Reviewer Agent**: [Agent name]
**Project**: Ignixxion Digital Fleet - React Native Mobile

---

## Executive Summary
- **Overall Score**: X/10
- **Critical Issues**: N found
- **Recommendations**: N items
- **Files Reviewed**: N files

[2-3 sentence high-level summary]

---

## ✅ Positive Findings
- [Item 1] - `file/path.ts:123`
- [Item 2] - `file/path.ts:456`

---

## 🔴 Critical Issues (Must Fix)

### Issue #1: [Issue Title]
**Severity**: 🔴 Critical
**File**: `path/to/file.tsx:45-67`
**Impact**: [Business/technical impact]

**Problem**:
[Detailed description with code examples]

```typescript
// ❌ Current (Problematic)
const badExample = () => { ... };
```

**Solution**:
```typescript
// ✅ Recommended
const goodExample = () => { ... };
```

**References**:
- [React Native Docs](url)
- [OWASP Mobile](url)

---

## 🟡 Recommendations (Should Fix)

### Recommendation #1: [Title]
**Priority**: Medium
**File**: `path/to/file.tsx`
**Effort**: [Low/Medium/High]

[Description with code examples]

---

## 💡 Suggestions (Nice to Have)

### Suggestion #1: [Title]
**Priority**: Low
**File**: `path/to/file.tsx`

[Description]

---

## 📈 Metrics

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| [Metric 1] | 75% | 90% | 🟡 |
| [Metric 2] | 95% | 90% | ✅ |

---

## 🔄 Action Items

- [ ] **[Priority]** [Task description] - `file.tsx:123` - Assigned: Team
- [ ] **[Priority]** [Task description] - `file.tsx:456` - Assigned: Team

---

## 📚 Additional Resources
- [Resource 1](url)
- [Resource 2](url)
```

### Emoji Legend
- 🔴 Critical / Must Fix
- 🟡 Warning / Should Fix
- 🟢 Success / Good
- 💡 Suggestion / Nice to Have
- 📊 Metrics / Analytics
- ✅ Checklist / Done
- ❌ Problem / Error
- 🔄 Action Item
- 📁 File / Directory
- 🎯 Goal / Target

---

## Project Context: Ignixxion Digital Fleet

**Tech Stack:**
- React Native 0.81.4 + React 19.1.0
- Expo SDK 54 (managed workflow)
- TypeScript (strict mode)
- Redux Toolkit state management
- React Navigation 7
- Firebase (Auth + Messaging)
- Atomic Design architecture
- Jest + Detox testing

## Review Configuration

- **Standard Review**: Comprehensive mobile app review (default)
- **TDD-Enhanced Review**: Includes TDD compliance and test-first verification
  - Enable with **--tdd-review** flag
  - Verifies red-green-refactor cycle adherence
  - Checks test-first implementation patterns

**EXECUTION MODE: FULLY PARALLEL**

All review stages (1-13) are completely independent and MUST be executed simultaneously in a single parallel Task tool invocation. DO NOT execute stages sequentially or in phases. Each agent operates independently and saves their output to the specified markdown file in code_review/ folder without requiring results from other agents.

---

## Stage 1: Mobile Code Quality & React Native Patterns Review

**Output File**: `code_review/01_mobile_code_quality.md`

**Agent**: Use Task tool with subagent_type="mobile-developer"

**Prompt**:
```
Review React Native code quality and mobile development patterns for: $ARGUMENTS.

Generate/update a comprehensive markdown report and save it to 'code_review/01_mobile_code_quality.md'.

Include the following sections:
1. Executive Summary with overall code quality score
2. React Native 0.81.4 best practices adherence
3. Expo SDK 54 pattern compliance
4. Hermes engine optimization opportunities
5. FlatList performance and optimization
6. React 19 patterns and hooks usage
7. Component lifecycle management
8. Native module integration quality
9. Platform-specific code organization (.ios.tsx vs .android.tsx)
10. StyleSheet usage and optimization
11. Critical issues with code examples (Current ❌ vs Recommended ✅)
12. Metrics table showing RN pattern compliance
13. Action items checklist

Use the standard formatting template with emojis, code blocks, and file references.
```

**Expected Output Sections**:
```markdown
# 1. Mobile Code Quality & React Native Patterns Review

## 📊 Executive Summary
- **Overall Score**: 8/10
- **Critical Issues**: 3 found
- **Recommendations**: 7 items
- **Files Reviewed**: 45 files

## ✅ Positive Findings
- Proper use of React.memo in VehicleCard component
- Excellent FlatList optimization with getItemLayout
- Good platform-specific code separation

## 🔴 Critical Issues (Must Fix)

### Issue #1: Improper FlatList keyExtractor Usage
**Severity**: 🔴 Critical
**File**: `src/components/organisms/VehicleList.tsx:67-89`
**Impact**: Performance degradation, unnecessary re-renders

[Full issue template with code examples]

## 📈 Metrics
| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| React Native Pattern Compliance | 85% | 95% | 🟡 |
| Hermes Optimization | 70% | 90% | 🟡 |
| Platform-Specific Code | 95% | 90% | ✅ |
```

---

## Stage 2: TypeScript Strict Mode & Type Safety Review

**Output File**: `code_review/02_typescript_review.md`

**Agent**: Use Task tool with subagent_type="typescript-pro"

**Prompt**:
```
Review TypeScript implementation with strict mode for: $ARGUMENTS.

Generate/update a comprehensive markdown report and save it to 'code_review/02_typescript_review.md'.

Include the following sections:
1. Executive Summary with TypeScript compliance score
2. Strict mode violations and fixes
3. Redux Toolkit typing (RootState, AppDispatch, slices, thunks)
4. React Navigation types (param lists, navigation props)
5. Firebase type definitions and API types
6. Generic constraints and utility type usage
7. Path alias usage (@VisaGoRN/*, @/*)
8. Type inference optimization opportunities
9. Critical type safety issues with examples
10. Metrics table for type coverage and strict mode compliance
11. Action items for type improvements

Use the standard formatting template with before/after code examples.
```

**Expected Metrics**:
- TypeScript Strict Mode Compliance: X%
- Type Coverage: X%
- Any usage: X occurrences
- Redux Type Safety: X/10
- Navigation Type Safety: X/10

---

## Stage 3: React Component Architecture & Atomic Design Review

**Output File**: `code_review/03_architecture_review.md`

**Agent**: Use Task tool with subagent_type="architect-review"

**Prompt**:
```
Review React Native architecture and Atomic Design patterns for: $ARGUMENTS.

Generate/update a comprehensive markdown report and save it to 'code_review/03_architecture_review.md'.

Include the following sections:
1. Executive Summary with architecture score
2. Atomic Design hierarchy analysis (atoms → molecules → organisms → templates → pages)
3. Component structure and organization
4. Separation of concerns evaluation
5. Redux state architecture assessment
6. Repository pattern implementation review
7. Firebase integration architecture
8. Scalability assessment
9. Architectural violations and refactoring opportunities
10. Component dependency graph insights
11. Metrics table for architectural compliance
12. Refactoring action items

Use architectural diagrams where helpful (mermaid syntax).
```

**Expected Metrics**:
- Atomic Design Compliance: X%
- Component Coupling Score: X/10
- Redux Architecture Score: X/10
- Code Organization Score: X/10

---

## Stage 4: Mobile-Specific Security Audit

**Output File**: `code_review/04_mobile_security_audit.md`

**Agent**: Use Task tool with subagent_type="mobile-security-coder"

**Prompt**:
```
Perform mobile security audit for: $ARGUMENTS.

Generate/update a comprehensive markdown report and save it to 'code_review/04_mobile_security_audit.md'.

Include the following sections:
1. Executive Summary with security score
2. Firebase Auth security review
3. Secure storage audit (react-native-encrypted-storage)
4. Deep link validation security
5. Payment integration security (Stripe PCI-DSS)
6. NFC/barcode scanning security
7. Camera and native permissions security
8. Data encryption practices
9. Sensitive data handling in Redux state
10. OWASP MASVS compliance assessment
11. Critical security vulnerabilities with remediation
12. Security metrics and compliance scores
13. Security action items with priority

Include code examples showing insecure ❌ vs secure ✅ patterns.
```

**Expected Metrics**:
- OWASP MASVS Compliance: X%
- Firebase Security Score: X/10
- Secure Storage Implementation: X/10
- Authentication Security: X/10

---

## Stage 5: Frontend Security & XSS Prevention Review

**Output File**: `code_review/05_frontend_security_review.md`

**Agent**: Use Task tool with subagent_type="frontend-security-coder"

**Prompt**:
```
Review frontend security patterns for: $ARGUMENTS.

Generate/update a comprehensive markdown report and save it to 'code_review/05_frontend_security_review.md'.

Include the following sections:
1. Executive Summary with frontend security score
2. Input sanitization review
3. WebView security (if WebView is used)
4. Redux state security audit
5. Deep link parameter validation
6. Client-side data protection
7. React component injection prevention
8. Navigation param validation security
9. Form input security
10. Security vulnerabilities with code examples
11. Security metrics table
12. Security remediation action items

Show insecure ❌ vs secure ✅ code patterns.
```

**Expected Metrics**:
- Input Validation Coverage: X%
- Deep Link Security: X/10
- Redux State Security: X/10
- Component Security: X/10

---

## Stage 6: React Native Performance & Optimization Analysis

**Output File**: `code_review/06_performance_analysis.md`

**Agent**: Use Task tool with subagent_type="performance-engineer"

**Prompt**:
```
Analyze mobile performance for: $ARGUMENTS.

Generate/update a comprehensive markdown report and save it to 'code_review/06_performance_analysis.md'.

Include the following sections:
1. Executive Summary with performance score
2. React Native rendering bottleneck analysis
3. FlatList optimization opportunities
4. Image loading performance (expo-image-picker)
5. Redux selector performance analysis
6. React Navigation performance
7. Bundle size analysis and optimization
8. Hermes profiling results
9. Memory leak detection
10. Startup time optimization
11. Performance metrics table with targets
12. Performance optimization action items with impact estimates

Include Flipper profiling screenshots or data where available.
```

**Expected Metrics**:
| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| App Startup Time | 3.2s | < 2s | 🔴 |
| Bundle Size | 6.5MB | < 5MB | 🟡 |
| FlatList FPS | 55 FPS | 60 FPS | 🟡 |
| Memory Usage | 180MB | < 200MB | ✅ |

---

## Stage 7: Mobile UI/UX & Design System Review

**Output File**: `code_review/07_ui_ux_review.md`

**Agent**: Use Task tool with subagent_type="ui-ux-designer"

**Prompt**:
```
Review mobile UI/UX design for: $ARGUMENTS.

Generate/update a comprehensive markdown report and save it to 'code_review/07_ui_ux_review.md'.

Include the following sections:
1. Executive Summary with UI/UX score
2. Atomic Design implementation review
3. iOS Human Interface Guidelines compliance
4. Material Design adherence (Android)
5. Touch target sizing audit (44x44pt iOS, 48x48dp Android)
6. Navigation UX evaluation
7. Platform-specific design patterns
8. Accessibility standards (WCAG AA)
9. Responsive mobile layout analysis
10. Dark mode support
11. UI/UX issues with screenshots/mockups
12. Design metrics table
13. UX improvement action items

Include visual examples and comparisons where helpful.
```

**Expected Metrics**:
- iOS HIG Compliance: X%
- Material Design Compliance: X%
- Touch Target Compliance: X%
- Accessibility Score: X/10
- Dark Mode Support: X%

---

## Stage 8: Visual Component Validation

**Output File**: `code_review/08_visual_validation.md`

**Agent**: Use Task tool with subagent_type="ui-visual-validator"

**Prompt**:
```
Validate visual implementation for: $ARGUMENTS.

Generate/update a comprehensive markdown report and save it to 'code_review/08_visual_validation.md'.

Include the following sections:
1. Executive Summary with visual validation score
2. iOS vs Android visual consistency analysis
3. Atomic Design component structure validation
4. Dark mode support verification
5. Platform-specific styling review
6. Responsive behavior across screen sizes
7. Touch target size validation
8. Safe area handling (notch, home indicator)
9. Visual regression issues
10. Screenshot comparison results (if available)
11. Visual validation metrics
12. Visual fix action items

Include visual examples, screenshots, or mockups where helpful.
```

**Expected Metrics**:
- Cross-Platform Consistency: X%
- Touch Target Compliance: X%
- Dark Mode Support: X%
- Safe Area Handling: X/10

---

## Stage 9: Redux Toolkit State Management Review

**Output File**: `code_review/09_redux_state_review.md`

**Agent**: Use Task tool with subagent_type="code-reviewer"

**Prompt**:
```
Review Redux Toolkit state management for: $ARGUMENTS.

Generate/update a comprehensive markdown report and save it to 'code_review/09_redux_state_review.md'.

Include the following sections:
1. Executive Summary with Redux architecture score
2. Slice patterns and structure analysis
3. Async thunk implementation review
4. RTK Query usage (if applicable)
5. Selector optimization and memoization
6. Middleware configuration review
7. State normalization assessment (createEntityAdapter)
8. Redux DevTools integration
9. Redux state security (no sensitive data)
10. Redux persist configuration
11. State management issues with code examples
12. Redux metrics table
13. State architecture action items

Show before ❌ and after ✅ code patterns.
```

**Expected Metrics**:
- Slice Pattern Compliance: X%
- State Normalization: X%
- Selector Performance: X/10
- Redux DevTools Security: Pass/Fail

---

## Stage 10: Mobile Testing Strategy & Coverage Assessment

**Output File**: `code_review/10_testing_strategy.md`

**Agent**: Use Task tool with subagent_type="test-automator"

**Prompt**:
```
Evaluate mobile testing strategy for: $ARGUMENTS.

Generate/update a comprehensive markdown report and save it to 'code_review/10_testing_strategy.md'.

Include the following sections:
1. Executive Summary with testing strategy score
2. Jest unit test analysis
3. React Native Testing Library component tests
4. Detox E2E test coverage
5. Redux testing patterns (slices, thunks, selectors)
6. Firebase mocking strategy
7. Navigation testing review
8. Snapshot test coverage
9. Test coverage metrics and gaps
10. Test quality assessment
11. Missing test scenarios
12. Testing metrics table
13. Test implementation action items

Include test coverage reports and metrics.
```

**Expected Metrics**:
| Test Type | Coverage | Target | Status |
|-----------|----------|--------|--------|
| Unit Tests (Jest) | 75% | 80% | 🟡 |
| Component Tests | 60% | 80% | 🔴 |
| E2E Tests (Detox) | 40% | 60% | 🟡 |
| Redux Tests | 85% | 90% | 🟡 |

---

## Stage 11: Comprehensive Security Audit & Compliance

**Output File**: `code_review/11_security_compliance.md`

**Agent**: Use Task tool with subagent_type="security-auditor"

**Prompt**:
```
Perform comprehensive security audit for: $ARGUMENTS.

Generate/update a comprehensive markdown report and save it to 'code_review/11_security_compliance.md'.

Include the following sections:
1. Executive Summary with overall security score
2. Firebase security rules review
3. OWASP Mobile Security (MASVS) compliance
4. Authentication flow security analysis
5. Data encryption assessment
6. API security review
7. Third-party SDK security (Stripe, Notifee, etc.)
8. Mobile-specific vulnerability assessment
9. Root/jailbreak detection
10. Certificate pinning review
11. Security compliance matrix
12. Critical security issues with severity ratings
13. Security remediation roadmap

Include OWASP MASVS compliance checklist.
```

**Expected Metrics**:
- OWASP MASVS Compliance: X% (L1/L2)
- Firebase Security Score: X/10
- API Security Score: X/10
- Third-Party SDK Security: X/10
- Overall Security Rating: Low/Medium/High Risk

---

## Stage 12: DevOps & Mobile Build Configuration Review

**Output File**: `code_review/12_devops_build_config.md`

**Agent**: Use Task tool with subagent_type="devops-troubleshooter"

**Prompt**:
```
Review mobile build configuration and DevOps setup for: $ARGUMENTS.

Generate/update a comprehensive markdown report and save it to 'code_review/12_devops_build_config.md'.

Include the following sections:
1. Executive Summary with DevOps maturity score
2. iOS build configuration review (Xcode, Podfile)
3. Android build configuration review (Gradle, AndroidManifest)
4. Expo configuration analysis (app.config.js, eas.json)
5. Environment variables management (.env)
6. Firebase configuration (google-services.json, GoogleService-Info.plist)
7. Code signing setup (iOS provisioning, Android keystore)
8. CI/CD pipeline analysis
9. Deployment workflow review
10. Build optimization opportunities
11. DevOps configuration issues
12. Build metrics and performance
13. DevOps improvement action items

Include build configuration examples and CI/CD pipeline diagrams.
```

**Expected Metrics**:
- Build Success Rate: X%
- Average Build Time: X minutes
- Deployment Frequency: X/week
- Environment Config Security: Pass/Fail

---

## Stage 13: TDD Compliance Review (Optional - when --tdd-review enabled)

**Output File**: `code_review/13_tdd_compliance.md`

**Agent**: Use Task tool with subagent_type="tdd-orchestrator"

**Prompt**:
```
Verify TDD compliance for: $ARGUMENTS.

Generate/update a comprehensive markdown report and save it to 'code_review/13_tdd_compliance.md'.

Include the following sections:
1. Executive Summary with TDD adherence score
2. Test-first verification (commit history analysis)
3. Red-green-refactor cycle evidence
4. Test coverage trend analysis
5. Mobile-specific test quality (RN components, hooks, navigation)
6. Refactoring evidence with test safety nets
7. TDD anti-patterns identified
8. Test code quality assessment
9. TDD compliance violations
10. TDD metrics dashboard
11. TDD improvement recommendations
12. TDD adoption action plan

Analyze git commit history to verify test-first patterns.
```

**Expected Metrics**:
- TDD Adherence Score: X%
- Test-First Commits: X%
- Red-Green-Refactor Cycles: X detected
- Test Coverage Growth: +X% during feature development
- Refactoring Cycles with Tests: X instances

---

## Final Stage: Consolidated Report

**Output File**: `code_review/00_consolidated_report.md`

**Created By**: Primary orchestrator after all stage reviews complete

**Structure**:
```markdown
# Consolidated Code Review Report

**Project**: Ignixxion Digital Fleet - React Native Mobile
**Review Date**: YYYY-MM-DD
**Reviewed By**: Multi-Agent Review System
**Review Scope**: $ARGUMENTS

---

## 📊 Executive Dashboard

| Category | Score | Critical | Warnings | Pass |
|----------|-------|----------|----------|------|
| Mobile Code Quality | 8/10 | 3 | 7 | 15 |
| TypeScript Safety | 7/10 | 5 | 10 | 20 |
| Architecture | 9/10 | 1 | 3 | 12 |
| Security | 6/10 | 8 | 5 | 10 |
| Performance | 7/10 | 2 | 9 | 8 |
| UI/UX | 8/10 | 1 | 4 | 18 |
| Testing | 6/10 | 0 | 12 | 15 |
| DevOps | 7/10 | 2 | 6 | 10 |

**Overall Project Health**: 🟡 Good (74/100)

---

## 🎯 Key Findings Summary

### Strengths
1. **Excellent Atomic Design Implementation** - Well-structured component hierarchy
2. **Strong Redux Toolkit Usage** - Proper slice patterns and normalization
3. **Good Platform-Specific Code** - iOS/Android separation well maintained
4. **Firebase Integration** - Clean architecture and proper abstraction

### Areas of Concern
1. **Security Gaps** - Missing encryption for sensitive data
2. **Test Coverage** - Only 65% coverage, below 80% target
3. **Performance Issues** - Startup time exceeds 2s target
4. **TypeScript Violations** - 15 strict mode violations found

---

## 🔴 Critical Issues (MUST FIX) - Total: 22

### Security (8 issues)
1. **Firebase Auth tokens in AsyncStorage** → Use react-native-encrypted-storage
   - Files: `src/store/slices/authSlice.ts:45`
   - Severity: 🔴 Critical
   - [Link to detailed report](./04_mobile_security_audit.md#issue-1)

2. **Raw card data in Redux state** → Never store PCI data in state
   - Files: `src/store/slices/paymentSlice.ts:23`
   - Severity: 🔴 Critical
   - [Link to detailed report](./04_mobile_security_audit.md#issue-2)

[... continue for all 8 security issues]

### Performance (2 issues)
1. **FlatList causing scroll jank** → Implement getItemLayout and keyExtractor
   - Files: `src/components/organisms/VehicleList.tsx:67`
   - Severity: 🔴 Critical
   - [Link to detailed report](./06_performance_analysis.md#issue-1)

[... continue for all critical issues from each report]

---

## 🟡 Recommendations (SHOULD FIX) - Total: 56

### Code Quality (15 items)
1. **Optimize React.memo usage** → Reduce unnecessary re-renders
   - Priority: High
   - Effort: Medium
   - [Link to detailed report](./01_mobile_code_quality.md#rec-1)

### TypeScript (10 items)
### Architecture (8 items)
### UI/UX (12 items)
### Testing (11 items)

[... categorized recommendations from all reports]

---

## 💡 Suggestions (NICE TO HAVE) - Total: 34

### Refactoring Opportunities
### Documentation Improvements
### Developer Experience
### Advanced Patterns

---

## 📈 Comprehensive Metrics Dashboard

### Mobile-Specific Metrics

| Metric | Current | Target | Status | Trend |
|--------|---------|--------|--------|-------|
| React Native 0.81.4 Compliance | 85% | 95% | 🟡 | ↗️ |
| Expo SDK 54 Pattern Usage | 90% | 90% | ✅ | → |
| iOS/Android Parity | 92% | 90% | ✅ | ↗️ |
| App Startup Time | 3.2s | < 2s | 🔴 | ↘️ |
| Bundle Size (Compressed) | 6.5MB | < 5MB | 🟡 | → |
| FlatList Performance (FPS) | 55 | 60 | 🟡 | ↗️ |
| Memory Usage | 180MB | < 200MB | ✅ | ↗️ |
| Atomic Design Compliance | 88% | 90% | 🟡 | ↗️ |

### Quality Metrics

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| TypeScript Strict Mode | 92% | 100% | 🟡 |
| Type Coverage | 88% | 95% | 🟡 |
| Code Duplication | 8% | < 5% | 🟡 |
| Cyclomatic Complexity | 12 avg | < 10 | 🟡 |

### Testing Metrics

| Test Type | Coverage | Target | Gap | Status |
|-----------|----------|--------|-----|--------|
| Jest Unit Tests | 75% | 80% | -5% | 🟡 |
| Component Tests (RTL) | 60% | 80% | -20% | 🔴 |
| Detox E2E Tests | 40% | 60% | -20% | 🔴 |
| Redux Tests | 85% | 90% | -5% | 🟡 |
| **Overall Coverage** | **68%** | **80%** | **-12%** | 🔴 |

### Security Metrics

| Metric | Score | Status |
|--------|-------|--------|
| OWASP MASVS Compliance (L1) | 75% | 🟡 |
| Firebase Security | 7/10 | 🟡 |
| Secure Storage Implementation | 6/10 | 🟡 |
| Authentication Security | 8/10 | 🟢 |
| API Security | 7/10 | 🟡 |
| **Overall Security Rating** | **Medium Risk** | 🟡 |

### TDD Metrics (if --tdd-review enabled)

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| TDD Adherence Score | 45% | 80% | 🔴 |
| Test-First Commits | 38% | 70% | 🔴 |
| Red-Green-Refactor Cycles | 12 | N/A | 📊 |
| Test Coverage Growth | +8% | +10% | 🟡 |
| Test Execution Time | 2m 15s | < 2m | 🟡 |

---

## 🔄 Prioritized Action Plan

### Phase 1: Critical Security Fixes (Week 1-2)
- [ ] **P0** Migrate Firebase tokens to encrypted storage - `authSlice.ts`
- [ ] **P0** Remove sensitive data from Redux state - `paymentSlice.ts`
- [ ] **P0** Implement deep link validation - `navigation/linking.ts`
- [ ] **P0** Add certificate pinning for Firebase API - `api/config.ts`
- [ ] **P0** Fix NFC data validation - `hooks/useNFC.ts`
- [ ] **P0** Implement proper input sanitization - `components/forms/*`
- [ ] **P0** Add Redux DevTools production check - `store/index.ts`
- [ ] **P0** Fix WebView security config - `components/WebViewComponent.tsx`

**Estimated Effort**: 40 hours | **Business Impact**: High

### Phase 2: Performance Optimization (Week 3-4)
- [ ] **P1** Optimize FlatList with getItemLayout - `VehicleList.tsx`
- [ ] **P1** Reduce bundle size to < 5MB - Webpack config
- [ ] **P1** Improve startup time to < 2s - App initialization
- [ ] **P1** Fix memory leaks in image loading - Image components
- [ ] **P1** Optimize Redux selectors - All selectors
- [ ] **P1** Implement React.memo strategically - Performance-critical components

**Estimated Effort**: 32 hours | **Business Impact**: Medium-High

### Phase 3: Testing Coverage (Week 5-6)
- [ ] **P1** Add Jest tests for critical flows - 20+ test files
- [ ] **P1** Implement Detox E2E tests - Auth, Vehicle, Transaction flows
- [ ] **P1** Add Redux test coverage - All slices and thunks
- [ ] **P1** Implement snapshot tests - All Atomic Design atoms
- [ ] **P1** Add navigation tests - All navigation flows

**Estimated Effort**: 48 hours | **Business Impact**: Medium

### Phase 4: Code Quality Improvements (Week 7-8)
- [ ] **P2** Fix TypeScript strict mode violations - 15 files
- [ ] **P2** Implement missing Atomic Design patterns - Component refactoring
- [ ] **P2** Refactor duplicated code - Shared utilities
- [ ] **P2** Improve component documentation - TSDoc comments

**Estimated Effort**: 24 hours | **Business Impact**: Medium-Low

---

## 📚 Detailed Report Links

1. [Mobile Code Quality Review](./01_mobile_code_quality.md)
2. [TypeScript Safety Review](./02_typescript_review.md)
3. [Architecture Review](./03_architecture_review.md)
4. [Mobile Security Audit](./04_mobile_security_audit.md)
5. [Frontend Security Review](./05_frontend_security_review.md)
6. [Performance Analysis](./06_performance_analysis.md)
7. [UI/UX Review](./07_ui_ux_review.md)
8. [Visual Validation](./08_visual_validation.md)
9. [Redux State Review](./09_redux_state_review.md)
10. [Testing Strategy](./10_testing_strategy.md)
11. [Security Compliance](./11_security_compliance.md)
12. [DevOps Build Config](./12_devops_build_config.md)
13. [TDD Compliance](./13_tdd_compliance.md) *(if enabled)*

---

## 🎯 Success Criteria

### Definition of Done for Remediation
- [ ] All 🔴 Critical issues resolved
- [ ] Security rating improved to "Low Risk"
- [ ] Test coverage reaches 80%+
- [ ] Performance targets met (startup < 2s, bundle < 5MB)
- [ ] TypeScript strict mode 100% compliance
- [ ] OWASP MASVS L1 > 90% compliance

### Recommended Follow-up
1. **Weekly Security Reviews** - Ongoing security audit
2. **Monthly Performance Profiling** - Flipper analysis
3. **Quarterly Architecture Review** - Scalability assessment
4. **Continuous Testing** - Maintain 80%+ coverage

---

## 📞 Next Steps

1. **Review this consolidated report** with the development team
2. **Prioritize action items** based on business impact
3. **Create Jira/GitHub issues** for all critical and high-priority items
4. **Assign owners** for each action item
5. **Set sprint goals** for Phase 1 (Critical Security Fixes)
6. **Schedule follow-up review** after remediation

---

**Review Completed**: YYYY-MM-DD
**Next Review Scheduled**: YYYY-MM-DD (4 weeks)
```

---

## Review Options & Flags

- **--tdd-review**: Enable TDD compliance checking
- **--strict-tdd**: Fail review if TDD practices not followed
- **--tdd-metrics**: Generate/update detailed TDD metrics report
- **--test-first-only**: Only review code with test-first evidence
- **--ios-only**: Focus review on iOS-specific patterns
- **--android-only**: Focus review on Android-specific patterns
- **--performance-focus**: Deep dive into React Native performance
- **--security-focus**: Comprehensive mobile security audit

---

## 🚀 Workflow Execution Summary

### Pre-Review Checklist
- [ ] Ensure `code_review/` directory exists or will be created
- [ ] All specialized agents are available and configured
- [ ] Review scope defined: $ARGUMENTS
- [ ] Review options selected (if any)

### Execution Flow
1. **Create output directory**: `mkdir -p code_review/`
2. **Launch all review agents in parallel**: Spawn all 12-13 agents simultaneously in a single Task tool invocation
3. **Each agent runs independently**: All reviews execute concurrently without waiting for each other
4. **Monitor progress**: Track completion of each stage output file as agents finish
5. **Generate/update consolidated report**: After all agents complete, aggregate findings into `00_consolidated_report.md`
6. **Notify completion**: Present consolidated report to user

**CRITICAL EXECUTION INSTRUCTION**:
When executing this workflow, you MUST invoke all Task tools for stages 1-13 (1-12 standard, +13 if --tdd-review) in a SINGLE message using multiple Task tool calls in parallel. This ensures true parallel execution. DO NOT execute agents sequentially or wait for one to finish before starting another.

### Post-Review Actions
1. **Review the consolidated report** with stakeholders
2. **Create tracking tickets** for all critical issues
3. **Plan remediation sprints** based on prioritized action plan
4. **Schedule follow-up review** (recommended: 4 weeks)

---

## 📋 Quality Assurance for Review Outputs

**Each output file MUST contain:**
- ✅ Executive Summary with scores
- ✅ Positive findings section
- ✅ Critical issues with code examples (❌ vs ✅)
- ✅ Recommendations with priority and effort estimates
- ✅ Metrics table with current/target/status
- ✅ Actionable checklist items
- ✅ File references with line numbers (`file.tsx:123`)
- ✅ Links to resources and documentation
- ✅ Consistent emoji usage per legend
- ✅ Markdown table formatting
- ✅ Code blocks with language tags (typescript, bash, json)

**Consolidated report MUST contain:**
- ✅ Executive dashboard with category scores
- ✅ Key findings summary (strengths + concerns)
- ✅ Categorized critical issues with links to detailed reports
- ✅ Comprehensive metrics dashboard
- ✅ Prioritized action plan with phases and estimates
- ✅ Links to all individual review reports
- ✅ Success criteria and next steps

---

## 🎓 How to Use This Workflow

### Example Usage:

```bash
# Full review of entire src directory
/full-review src/

# Review specific feature
/full-review src/components/organisms/VehicleList.tsx

# Performance-focused review
/full-review src/ --performance-focus

# Security-focused review with TDD compliance
/full-review src/ --security-focus --tdd-review

# iOS-specific review
/full-review src/ --ios-only

# Review with strict TDD enforcement
/full-review src/features/auth/ --tdd-review --strict-tdd
```

### Expected Timeline:
- **Small scope** (1-5 files): 15-30 minutes
- **Medium scope** (feature/module): 30-60 minutes
- **Large scope** (entire app): 1-2 hours
- **Plus consolidation**: +15-30 minutes

### Deliverables:
- **12-13 detailed markdown reports** in `code_review/` folder
- **1 consolidated report** (`00_consolidated_report.md`)
- **Actionable insights** with prioritized remediation plan
- **Metrics dashboard** tracking project health
- **Links to resources** for remediation guidance

---

## 📖 Additional Notes

### Important Reminders:
- All reports use **consistent formatting** per the standard template
- All issues include **file references** with line numbers
- All code examples show **before ❌ and after ✅** patterns
- All metrics include **current, target, and status**
- All action items are **prioritized** (P0/P1/P2) with effort estimates
- The consolidated report provides **executive-level** summary

### Customization:
- Agents can be added/removed based on project needs
- Metrics targets can be adjusted per project standards
- Severity thresholds can be customized
- Review options can be combined for focused analysis

### Continuous Improvement:
- Review outputs improve with each iteration
- Metrics establish baseline for future comparisons
- Action plans create roadmap for quality improvement
- Follow-up reviews track progress over time

---

**Target**: $ARGUMENTS

**Created**: 2025
**Last Updated**: 2025-10-11
**Version**: 2.0 (Enhanced with detailed outputs and formatting)
