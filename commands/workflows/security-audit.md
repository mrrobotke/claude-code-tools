---
name: security-audit
description: Comprehensive security audit workflow that runs all security agents in parallel to perform a complete security assessment. Generates detailed reports covering authentication, authorization, input validation, infrastructure security, dependencies, database security, and configuration hygiene. All agents run simultaneously for maximum efficiency.
tools: Task, Write, Read, Run_terminal_cmd, TodoWrite
model: inherit
---

You are orchestrating a comprehensive security audit by coordinating multiple specialized security agents in parallel.

## Workflow Overview

This workflow performs a complete security audit by running all security agents simultaneously. Each agent produces specialized reports that are then aggregated into a comprehensive security assessment.

## Pre-Audit Setup

### 1. Create Audit Directory Structure in docs
```bash
docs/audits/
├── YYYY-MM-DD/
│   ├── api-security/
│   ├── auth/
│   ├── ci-cd/
│   ├── database/
│   ├── dependencies/
│   ├── http/
│   ├── observability/
│   ├── quality/
│   ├── secrets/
│   ├── static-analysis/
│   ├── validation/
│   └── orchestration/
```

### 2. Verify Prerequisites
- All source code is committed
- Test environment is running
- Security scanning tools are installed ( install them if not already installed)
- Audit permissions are configured

## Parallel Agent Execution

### Execute All Security Audits Simultaneously

```yaml
parallel_tasks:
  - sub_agent: nestjs-api-security
    id: api-security-audit
    prompt: |
      Perform comprehensive NestJS API security audit:
      1. Authentication & authorization architecture review
      2. Input validation and sanitization audit
      3. API security controls assessment
      4. Data protection evaluation
      5. Security testing coverage
      Output: docs/audits/api-security/SECURITY_AUDIT.md
    
  - sub_agent: auth-rbac-architect
    id: auth-audit
    prompt: |
      Audit authentication and authorization implementation:
      1. JWT implementation security
      2. Permission model effectiveness
      3. Guard and decorator patterns
      4. Session management
      5. Multi-tenant isolation
      Output: docs/audits/auth/AUTH_AUDIT.md
    
  - sub_agent: prisma-db-security
    id: database-audit
    prompt: |
      Audit database security and Prisma configuration:
      1. Row Level Security policies
      2. Query security and optimization
      3. Data encryption status
      4. Audit logging effectiveness
      5. Backup security
      Output: docs/audits/database/DATABASE_SECURITY_AUDIT.md
    
  - sub_agent: dependency-security
    id: dependency-audit
    prompt: |
      Scan and analyze dependency vulnerabilities:
      1. Run npm audit, Snyk, Retire.js
      2. Check for outdated packages
      3. License compliance verification
      4. Supply chain security assessment
      5. Generate SBOM
      Output: docs/audits/dependencies/VULNERABILITY_REPORT.md
    
  - sub_agent: secrets-config-hygiene
    id: secrets-audit
    prompt: |
      Audit secrets management and configuration:
      1. Scan for hardcoded secrets
      2. Environment configuration validation
      3. Git history secret scan
      4. Secret rotation policy review
      5. Configuration hygiene check
      Output: docs/audits/secrets/SECRETS_AUDIT.md
    
  - sub_agent: http-hardening
    id: http-audit
    prompt: |
      Audit HTTP security implementation:
      1. Security headers configuration
      2. CORS policy effectiveness
      3. Rate limiting implementation
      4. Request/response security
      5. TLS/SSL configuration
      Output: docs/audits/http/HTTP_SECURITY_AUDIT.md
    
  - sub_agent: dto-validation-enforcer
    id: validation-audit
    prompt: |
      Audit input validation and DTOs:
      1. DTO validation coverage
      2. Custom validator effectiveness
      3. File upload security
      4. Sanitization implementation
      5. Edge case handling
      Output: docs/audits/validation/VALIDATION_AUDIT.md
    
  - sub_agent: static-analysis
    id: static-analysis-audit
    prompt: |
      Run static code analysis for security:
      1. SonarQube security hotspots
      2. Semgrep security rules
      3. CodeQL vulnerability detection
      4. Code quality metrics
      5. Security anti-patterns
      Output: docs/audits/static-analysis/STATIC_ANALYSIS_REPORT.md
    
  - sub_agent: ci-cd-security-orchestrator
    id: cicd-audit
    prompt: |
      Audit CI/CD pipeline security:
      1. Security gate effectiveness
      2. Dependency scanning integration
      3. SAST tool configuration
      4. Build artifact security
      5. Deployment security
      Output: docs/audits/ci-cd/CICD_SECURITY_AUDIT.md
    
  - sub_agent: observability-incident-response
    id: observability-audit
    prompt: |
      Audit observability and incident response:
      1. Security event logging coverage
      2. Monitoring effectiveness
      3. Alert configuration review
      4. Incident response procedures
      5. Forensic capabilities
      Output: docs/audits/observability/OBSERVABILITY_AUDIT.md
    
  - sub_agent: gatekeeper
    id: quality-audit
    prompt: |
      Audit code quality gates:
      1. Linting rule effectiveness
      2. Type safety enforcement
      3. Test coverage analysis
      4. Code complexity metrics
      5. Quality gate configuration
      Output: docs/audits/quality/QUALITY_REPORT.md
```

## Post-Audit Report Generation

### Wait for All Agents to Complete

Once all parallel tasks complete, generate the comprehensive report:

```yaml
sequential_task:
  sub_agent: audit-reporter
  prompt: |
    Aggregate all security audit findings:
    1. Collect reports from all audit subdirectories
    2. Deduplicate findings across different audits
    3. Calculate overall risk scores
    4. Generate executive summary
    5. Create remediation roadmap
    6. Produce compliance mapping
    
    Input directories:
    - docs/audits/api-security/
    - docs/audits/auth/
    - docs/audits/database/
    - docs/audits/dependencies/
    - docs/audits/secrets/
    - docs/audits/http/
    - docs/audits/validation/
    - docs/audits/static-analysis/
    - docs/audits/ci-cd/
    - docs/audits/observability/
    - docs/audits/quality/
    
    Outputs:
    - docs/audits/YYYY-MM-DD/EXECUTIVE_SUMMARY.md
    - docs/audits/YYYY-MM-DD/TECHNICAL_REPORT.md
    - docs/audits/YYYY-MM-DD/REMEDIATION_PLAN.md
    - docs/audits/YYYY-MM-DD/findings.json
    - docs/audits/YYYY-MM-DD/metrics.json
```

## Execution Instructions

### 1. Initialize Audit
```bash
# Create audit directory
export AUDIT_DATE=$(date +%Y-%m-%d)
mkdir -p docs/audits/$AUDIT_DATE/{api-security,auth,ci-cd,database,dependencies,http,observability,quality,secrets,static-analysis,validation,orchestration}

# Install security tools
npm install -g snyk retire gitleaks
npm install --save-dev @microsoft/rush-lib semgrep
```

### 2. Launch Parallel Execution
All agents run simultaneously with no dependencies between them. This maximizes efficiency and reduces total audit time.

### 3. Monitor Progress
Track agent progress through their individual output files. Each agent writes progress updates to their respective audit directories.

### 4. Verify Completion
Ensure all agents have completed before running the final report aggregation.

## Expected Outputs

### Individual Agent Reports
Each agent produces specialized reports in their designated directories:

1. **API Security** (`docs/audits/api-security/`)
   - SECURITY_AUDIT.md
   - vulnerabilities.json
   - security-tests.md

2. **Authentication** (`docs/audits/auth/`)
   - AUTH_AUDIT.md
   - permission-matrix.csv
   - rbac-analysis.json

3. **Database Security** (`docs/audits/database/`)
   - DATABASE_SECURITY_AUDIT.md
   - rls-policies.sql
   - query-analysis.json

4. **Dependencies** (`docs/audits/dependencies/`)
   - VULNERABILITY_REPORT.md
   - npm-audit.json
   - snyk-results.json
   - licenses.json

5. **Secrets** (`docs/audits/secrets/`)
   - SECRETS_AUDIT.md
   - exposed-secrets.json
   - rotation-schedule.md

6. **HTTP Security** (`docs/audits/http/`)
   - HTTP_SECURITY_AUDIT.md
   - headers-analysis.json
   - cors-config.md

7. **Validation** (`docs/audits/validation/`)
   - VALIDATION_AUDIT.md
   - dto-coverage.json
   - sanitization-gaps.md

8. **Static Analysis** (`docs/audits/static-analysis/`)
   - STATIC_ANALYSIS_REPORT.md
   - sonarqube-report.json
   - semgrep-findings.json

9. **CI/CD Security** (`docs/audits/ci-cd/`)
   - CICD_SECURITY_AUDIT.md
   - pipeline-vulnerabilities.json
   - gate-effectiveness.md

10. **Observability** (`docs/audits/observability/`)
    - OBSERVABILITY_AUDIT.md
    - logging-coverage.json
    - incident-readiness.md

11. **Quality Gates** (`docs/audits/quality/`)
    - QUALITY_REPORT.md
    - gate-status.json
    - metrics.json

### Aggregated Reports
The audit-reporter agent produces:

1. **Executive Summary** (`docs/audits/YYYY-MM-DD/EXECUTIVE_SUMMARY.md`)
   - High-level risk assessment
   - Critical findings summary
   - Business impact analysis
   - Compliance status

2. **Technical Report** (`docs/audits/YYYY-MM-DD/TECHNICAL_REPORT.md`)
   - Detailed vulnerability analysis
   - Code examples and fixes
   - Technical recommendations
   - Security architecture review

3. **Remediation Plan** (`docs/audits/YYYY-MM-DD/REMEDIATION_PLAN.md`)
   - Prioritized action items
   - Timeline and effort estimates
   - Resource requirements
   - Success metrics

4. **Machine-Readable Data**
   - findings.json (all findings in structured format)
   - metrics.json (security metrics and KPIs)

## Quality Assurance

### Validation Checklist
- [ ] All agents completed successfully
- [ ] No missing audit categories
- [ ] Reports contain actionable findings
- [ ] Risk scores are consistent
- [ ] Remediation steps are clear
- [ ] No duplicate findings
- [ ] Compliance mappings are complete

### Common Issues and Solutions

1. **Agent Timeout**
   - Increase agent execution timeout
   - Split large codebases into modules

2. **Tool Installation Failures**
   - Use containerized security tools
   - Provide fallback scanning options

3. **Report Aggregation Errors**
   - Validate individual report formats
   - Handle missing report gracefully

## Post-Audit Actions

1. **Immediate (24 hours)**
   - Address critical vulnerabilities
   - Rotate exposed secrets
   - Apply emergency patches

2. **Short-term (1 week)**
   - Fix high-severity issues
   - Update security policies
   - Enhance monitoring

3. **Long-term (1 month)**
   - Implement architectural changes
   - Enhance security training
   - Update security procedures

## Continuous Improvement

1. **Metrics Tracking**
   - Time to complete audit
   - Number of findings by category
   - False positive rate
   - Remediation velocity

2. **Process Enhancement**
   - Update agent prompts based on findings
   - Add new security checks
   - Improve report formats
   - Automate remediation

3. **Knowledge Sharing**
   - Document new attack vectors
   - Share security patterns
   - Update security playbooks
