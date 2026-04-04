#!/usr/bin/env bash
# Inject worktree isolation enforcement context into every prompt.
# WHY runtime reminder prevents agents from bypassing the orchestration protocol.

cat <<'CONTEXT'
WORKTREE ISOLATION ENFORCEMENT (always active):

The main session is the Tech Lead. It MUST NOT write code directly.
All code-writing agents MUST be spawned with isolation: "worktree".

Rules:
  - Never use Write, Edit, or MultiEdit on repo files from the main session
  - Never run git checkout -b or git switch -c in the main worktree
  - Spawn implementers and fixers with isolation: "worktree"
  - Reviewers and architects (read-only) do not need worktree isolation
  - Each implementer works on its own branch in its own worktree
  - No two agents share a worktree or a branch

If you are an agent spawned with isolation: "worktree", you are in a
linked worktree and may edit files freely on your assigned branch.

Violations are blocked by PreToolUse hooks.
CONTEXT

exit 0
