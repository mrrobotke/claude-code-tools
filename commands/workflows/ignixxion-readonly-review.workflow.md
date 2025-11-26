---
model: inherit
---

Run this in a clean Claude Code session. Paste the migration brief as $BRIEF. Ensure the two repos are available on disk

- Ignixxion.DM.API/functions
- IgnixxionNestAPI
## PRECONDITIONS
- Since the primary task is to review what ahs been done. The workflow should spawn all agents in parallel and run them in parallel.
- The workflow should use the Task tool to run the agents.

### Phase A - Repository inventory and plan audit

1) Use Task tool with subagent_type="repo-inventory"  
Prompt:  
"Scan Ignixxion.DM.API/functions and IgnixxionNestAPI. Produce inventory.json with firebaseFunctions helpers nestModules prismaModels and a summary of hotspots. Do not modify any files. Respect read only mode."

Output:  
- inventory.json at IgnixxionNestAPI/migration_docs/inventory.json

2) Use Task tool with subagent_type="function-mapper"  
Prompt:  
"Read inventory.json. Draft FUNCTION_MAPPING_v2.md that maps every Firebase function to a Nest route and controller. Preserve existing wire names. Mark auth needs and deprecations. Do not write stubs. Read only."

Output:  
- FUNCTION_MAPPING_v2.md in memory and attached to the session

3) Use Task tool with subagent_type="schema-indexer"  
Prompt:  
"Read prisma/schema.prisma. Propose required @@index and @@unique entries for query paths and RLS predicates. Do not write migrations. Output rationale only."

Output:  
- prisma-index-review.md in memory

4) Use Task tool with subagent_type="auth-security"  
Prompt:  
"Audit current auth shape from Firebase side and Nest plan. Identify token issuers, roles and scopes. Identify public route risks. Produce AUTH_GAPS.md. Do not change code."

5) Use Task tool with subagent_type="swagger-qa"  
Prompt:  
"Generate swagger.json from current Nest project if present. Report missing decorators and DTO validation gaps. Produce swagger-coverage-report.md. Do not edit code."

6) Use Task tool with subagent_type="ci-cd-sentinel"  
Prompt:  
"Audit CI CD as per IgnixxionNestAPI/migration_docs/MIGRATION_PLAN.md. Confirm steps for lint typecheck build test prisma migrate deploy rollback swagger publish. Output ci-cd-review.md. Read only."

7) Use Task tool with subagent_type="infra-gcp"  
Prompt:  
"Audit Cloud Run to Cloud SQL connectivity plan. Check connector use, connection budgets, Secret Manager, IAM, network egress. Suggest PgBouncer only as a recommendation. Output gcp-infra-review.md. Read only."

8) Use Task tool with subagent_type="migration-verifier"  
Prompt:  
"From FUNCTION_MAPPING.md and v2 draft build a parity checklist. Compare current endpoints versus targets. Identify data validation queries and canary metrics. Output parity-report.md. Read only."

### Phase B - Consolidate into artifacts.json

9) Use Task tool with subagent_type="ignixxion-migration-supervisor"  
Prompt:  
"Merge all read only findings into a single artifacts.json. Include current status and remaining work by domain. Use the schema below. Write the file to IgnixxionNestAPI/migration_docs/artifacts.json"

Required JSON schema for artifacts.json  
{
  "summary": {
    "phase": "string",
    "overall_status": "green or yellow or red",
    "notes": "string"
  },
  "sections": {
    "migration_plan": {
      "v1_path": "IgnixxionNestAPI/migration_docs/MIGRATION_PLAN.md",
      "tasks": [
        {"id": "1.2", "title": "Dependencies and runtime", "status": "unknown or done or missing", "gaps": ["string"]},
        {"id": "1.3", "title": "DB migration", "status": "done", "evidence": ["file or commit"]}
      ]
    },
    "function_mapping": {
      "coverage_percent": 0,
      "unmapped_functions": ["string"],
      "renames_proposed": ["string"]
    },
    "swagger": {
      "coverage_percent": 0,
      "missing": ["Controller.method"]
    },
    "prisma_indexes": {
      "proposals": [{"model": "string", "index": "fields", "reason": "string"}]
    },
    "auth_security": {
      "token_sources": ["string"],
      "public_route_risks": ["string"],
      "rbac_scope_gaps": ["string"]
    },
    "ci_cd": {
      "gates_present": ["string"],
      "gates_missing": ["string"]
    },
    "infra_gcp": {
      "findings": ["string"],
      "recommendations": ["string"]
    },
    "rollout": {
      "canary_metrics": ["string"],
      "abort_rules": ["string"]
    }
  },
  "by_domain": {
    "admin": {"status": "todo or in_progress or done", "items": ["string"]},
    "pismo": {"status": "todo or in_progress or done", "items": ["string"]},
    "stripe": {"status": "todo or in_progress or done", "items": ["string"]},
    "other": {"status": "todo or in_progress or done", "items": ["string"]}
  },
  "inputs": {
    "brief": "$BRIEF",
    "repos": ["Ignixxion.DM.API/functions", "IgnixxionNestAPI"]
  }
}

Outputs written to disk  
- IgnixxionNestAPI/migration_docs/inventory.json  
- IgnixxionNestAPI/migration_docs/artifacts.json

Stop when artifacts.json exists with overall_status and at least one unmapped_functions entry evaluated

## Important
- To save time, the workflow should use the Task tool to run the agents in parallel and not syncronously.