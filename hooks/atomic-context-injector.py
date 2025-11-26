#!/usr/bin/env python3
"""
Injects atomic design guidelines into prompts for React projects
Always active in React projects provides contextual guidance
WHY proactive context helps agents maintain architectural consistency
"""

import json
import sys
import os
import re
from pathlib import Path

# Keywords that indicate React/frontend work
REACT_KEYWORDS = [
    'component', 'react', 'tsx', 'jsx', 'ui', 'button', 'form', 'input',
    'page', 'screen', 'template', 'layout', 'atom', 'molecule', 'organism',
    'render', 'props', 'state', 'hook', 'useeffect', 'usestate', 'usememo'
]

# File patterns that indicate React work
REACT_FILE_PATTERNS = [
    r'\.tsx',
    r'\.jsx',
    r'components?/',
    r'/atoms?/',
    r'/molecules?/',
    r'/organisms?/',
    r'/templates?/',
    r'/pages?/',
    r'design-system/',
    r'/ui/'
]

def is_react_project():
    """
    Detect if current directory is a React project
    Checks for package.json with react dependency
    """
    cwd = os.getcwd()

    # Check for package.json
    package_json_path = Path(cwd) / 'package.json'

    if not package_json_path.exists():
        # Check parent directories up to 3 levels
        for _ in range(3):
            cwd = str(Path(cwd).parent)
            package_json_path = Path(cwd) / 'package.json'
            if package_json_path.exists():
                break

    if not package_json_path.exists():
        return False

    try:
        with open(package_json_path, 'r', encoding='utf-8') as f:
            package_data = json.load(f)

            dependencies = package_data.get('dependencies', {})
            dev_dependencies = package_data.get('devDependencies', {})

            # Check for React
            if 'react' in dependencies or 'react' in dev_dependencies:
                return True

    except Exception:
        pass

    return False

def is_react_prompt(prompt):
    """
    Check if prompt mentions React/component keywords or file patterns
    """
    prompt_lower = prompt.lower()

    # Check for React keywords
    for keyword in REACT_KEYWORDS:
        if keyword in prompt_lower:
            return True

    # Check for file patterns
    for pattern in REACT_FILE_PATTERNS:
        if re.search(pattern, prompt_lower):
            return True

    return False

def main():
    try:
        input_data = json.load(sys.stdin)
        prompt = input_data.get("prompt", "")

        # Only inject context if in React project or prompt mentions React
        if not is_react_project() and not is_react_prompt(prompt):
            sys.exit(0)

        # Inject atomic design context
        context = """
ATOMIC DESIGN GUIDELINES (apply when building React components):

Directory Structure:
  Components must be in: src/design-system/ or src/ui/ or app/design-system/ or app/ui/

  Structure:
    design-system/
      atoms/        - Single-responsibility UI primitives (Button, Input, Icon)
      molecules/    - Combinations of atoms (SearchBar, Card, FormGroup)
      organisms/    - Complex sections (AppHeader, Sidebar, DataTable)
      templates/    - Page layouts with placeholder content
    pages/          - Concrete instances with real data (not in design-system/)

Atomic Hierarchy Rules:
  Level       | Can Import From
  ------------|--------------------------------------------------
  Atoms       | atoms, external libs only
  Molecules   | atoms, molecules, external libs
  Organisms   | atoms, molecules, organisms, external libs
  Templates   | atoms, molecules, organisms, templates, external libs
  Pages       | ALL levels

Boundary Rules (strictly enforced by hooks):
  Atoms:
    ✅ Accept data via props
    ✅ Handle visual state (hover, focus)
    ✅ Use ARIA attributes
    ❌ NO data fetching (fetch, useQuery, useSWR)
    ❌ NO routing (useNavigate, Link)
    ❌ NO global state (useDispatch, useSelector)

  Molecules:
    ✅ Compose atoms together
    ✅ Local form validation
    ✅ Forward events to parents
    ❌ NO routing or navigation
    ❌ NO direct API calls

  Organisms:
    ✅ Feature-complete sections
    ✅ Can fetch data IF they own that domain
    ✅ Coordinate child interactions
    ❌ NO page-level routing

  Templates:
    ✅ Define page structure and regions
    ✅ Accept content via props/children
    ❌ NO business logic (role checks, permissions)
    ❌ NO data fetching
    ❌ NO side effects

  Pages:
    ✅ Full integration and coordination
    ✅ Data fetching and routing
    ✅ Connect URL params to UI
    ✅ Error boundaries and loading states

File Structure (for each component):
  ComponentName/
    ├── ComponentName.tsx         - Main component
    ├── ComponentName.types.ts    - TypeScript interfaces
    ├── ComponentName.styles.ts   - Styles
    ├── ComponentName.test.tsx    - Vitest tests (required for templates/pages)
    └── index.ts                  - Re-exports

Testing Requirements:
  Atoms/Molecules:  Recommended (warnings if missing)
  Organisms:        Strongly recommended
  Templates/Pages:  REQUIRED (blocked without tests)

Accessibility (WCAG 2.1 AA):
  • Keyboard navigation (Tab, Enter, Escape, Arrows)
  • ARIA attributes (aria-label, aria-required, role)
  • Color contrast (4.5:1 for text, 3:1 for large text)
  • Semantic HTML (header, nav, main, aside, footer)
  • Visible focus indicators

Security:
  • No hardcoded secrets or API keys
  • Use environment variables (import.meta.env.VITE_*)
  • Validate all props with TypeScript (no 'any' types)
  • Sanitize user input if using dangerouslySetInnerHTML

Remember:
  1. Hooks will enforce these rules automatically
  2. Structure violations will be blocked
  3. Boundary violations will be blocked
  4. Missing tests for templates/pages will be blocked
  5. Always explain WHY a component belongs at a specific level
"""

        print(context)
        sys.exit(0)

    except Exception as e:
        print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(0)

if __name__ == '__main__':
    main()
