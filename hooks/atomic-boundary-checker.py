#!/usr/bin/env python3
"""
Scans component content for atomic boundary violations
Detects data fetching in atoms routing in molecules business logic in templates
WHY enforcing boundaries keeps components pure testable and reusable
"""

import json
import os
import sys
import re

# Violation patterns by atomic level
VIOLATION_PATTERNS = {
    'atoms': [
        {
            'pattern': r'\b(fetch|axios\.get|axios\.post|\.json\(\))\s*\(',
            'name': 'data_fetching',
            'message': 'Data fetching detected in atom',
            'rule': 'Atoms must be presentational and receive all data via props',
            'fix': 'Remove data fetching. Accept data as prop:\n\n' +
                   'interface Props {\n' +
                   '  data: YourDataType | null;\n' +
                   '  isLoading: boolean;\n' +
                   '}\n\n' +
                   'Let parent component handle fetching and pass data down.'
        },
        {
            'pattern': r'\b(useQuery|useSWR|useInfiniteQuery|useMutation)\s*\(',
            'name': 'query_hooks',
            'message': 'Query hook detected in atom',
            'rule': 'Atoms cannot use data fetching hooks',
            'fix': 'Remove query hook. Accept data and callbacks as props.'
        },
        {
            'pattern': r'\b(useNavigate|useRouter|useHistory|useLocation|useParams)\s*\(',
            'name': 'routing_hooks',
            'message': 'Routing hook detected in atom',
            'rule': 'Atoms have no navigation context',
            'fix': 'Remove routing hook. Accept onClick callback:\n\n' +
                   'interface Props {\n' +
                   '  onClick: () => void;\n' +
                   '}\n\n' +
                   'Let parent handle navigation:\n' +
                   '<Button onClick={() => navigate("/path")}>Click</Button>'
        },
        {
            'pattern': r'<(Link|NavLink|Navigate|Redirect)',
            'name': 'routing_components',
            'message': 'Routing component detected in atom',
            'rule': 'Atoms cannot contain navigation components',
            'fix': 'Use button with onClick callback instead of Link component.'
        },
        {
            'pattern': r'\b(useDispatch|useSelector|useStore|useAppDispatch|useAppSelector)\s*\(',
            'name': 'state_management',
            'message': 'Global state management detected in atom',
            'rule': 'Atoms should be stateless and receive data via props',
            'fix': 'Remove global state hooks. Accept state as props from parent.'
        }
    ],
    'molecules': [
        {
            'pattern': r'\b(useNavigate|useRouter|useHistory)\s*\(',
            'name': 'routing',
            'message': 'Routing detected in molecule',
            'rule': 'Molecules do not control navigation flow',
            'fix': 'Remove routing. Accept onNavigate callback:\n\n' +
                   'interface Props {\n' +
                   '  onNavigate: (path: string) => void;\n' +
                   '}\n\n' +
                   'Let parent (organism or page) handle routing.'
        },
        {
            'pattern': r'<(Navigate|Redirect)',
            'name': 'routing_components',
            'message': 'Navigation component detected in molecule',
            'rule': 'Molecules forward events to parents, they do not navigate',
            'fix': 'Replace with callback that parent can handle.'
        },
        {
            'pattern': r'\b(fetch|axios\.get|axios\.post)\s*\(',
            'name': 'direct_api_calls',
            'message': 'Direct API call detected in molecule',
            'rule': 'Molecules should receive data via props, not fetch directly',
            'fix': 'Remove API call. Accept data and loading state as props:\n\n' +
                   'interface Props {\n' +
                   '  items: Item[];\n' +
                   '  isLoading: boolean;\n' +
                   '  onRefresh: () => void;\n' +
                   '}'
        }
    ],
    'organisms': [
        {
            'pattern': r'fetch\s*\(\s*["\'][^"\']*\/api\/',
            'name': 'direct_api_path',
            'message': 'Direct API endpoint path detected',
            'rule': 'Organisms should use service layer instead of hardcoded API paths',
            'fix': 'Use service/API layer:\n\n' +
                   'import { fetchUsers } from "@/services/userService";\n\n' +
                   'const { data } = useQuery("users", fetchUsers);'
        }
    ],
    'templates': [
        {
            'pattern': r'if\s*\([^)]*\b(role|permission|isAdmin|isAuthenticated|user\.type)\s*(===|==|!==|!=)',
            'name': 'business_logic',
            'message': 'Business logic detected in template',
            'rule': 'Templates define layout only, no business logic',
            'fix': 'Move business logic to page:\n\n' +
                   'Template receives components as props:\n' +
                   '<Template sidebar={user.isAdmin ? <AdminSidebar /> : <UserSidebar />} />'
        },
        {
            'pattern': r'\b(useQuery|useSWR|fetch|axios)\s*\(',
            'name': 'data_fetching',
            'message': 'Data fetching detected in template',
            'rule': 'Templates use placeholder data, pages fetch real data',
            'fix': 'Remove data fetching. Templates receive children as props:\n\n' +
                   'interface Props {\n' +
                   '  children: ReactNode;\n' +
                   '  sidebar?: ReactNode;\n' +
                   '}'
        },
        {
            'pattern': r'\b(useEffect)\s*\([^,]*,\s*\[[^\]]*\]\s*\)',
            'name': 'side_effects',
            'message': 'Side effects detected in template',
            'rule': 'Templates are pure layout, side effects belong in pages',
            'fix': 'Move useEffect to page component that uses this template.'
        }
    ]
}

def detect_atomic_level(file_path):
    """
    Detect atomic level from file path
    """
    path_lower = file_path.lower()

    atomic_levels = ['atoms', 'molecules', 'organisms', 'templates', 'pages']

    for level in atomic_levels:
        if f'/{level}/' in path_lower:
            return level

    return None

def scan_for_violations(file_path, content):
    """
    Scan file content for boundary violations based on atomic level
    Returns list of violations with line numbers and fixes
    """
    violations = []

    level = detect_atomic_level(file_path)

    if level is None or level not in VIOLATION_PATTERNS:
        return []

    patterns = VIOLATION_PATTERNS[level]
    lines = content.split('\n')

    for pattern_def in patterns:
        pattern = pattern_def['pattern']
        matches = re.finditer(pattern, content, re.MULTILINE | re.IGNORECASE)

        for match in matches:
            # Find line number
            line_num = content[:match.start()].count('\n') + 1

            # Get the actual line content
            if line_num <= len(lines):
                line_content = lines[line_num - 1].strip()
            else:
                line_content = match.group(0)

            violations.append({
                'line': line_num,
                'code': line_content,
                'name': pattern_def['name'],
                'message': pattern_def['message'],
                'rule': pattern_def['rule'],
                'fix': pattern_def['fix']
            })

    return violations

def main():
    try:
        tool_input = json.loads(os.environ.get('CLAUDE_TOOL_INPUT', '{}'))
        file_path = tool_input.get('file_path', '')

        if not file_path:
            sys.exit(0)

        # Only check React component files
        if not (file_path.endswith('.tsx') or file_path.endswith('.jsx')):
            sys.exit(0)

        # Read file content
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        else:
            # File being created - use new content from tool input
            content = tool_input.get('content', '')

        if not content:
            sys.exit(0)

        # Scan for violations
        violations = scan_for_violations(file_path, content)

        if violations:
            level = detect_atomic_level(file_path)

            print("", file=sys.stderr)
            print("❌ ATOMIC BOUNDARY VIOLATION", file=sys.stderr)
            print(f"   File: {file_path}", file=sys.stderr)
            print(f"   Level: {level.capitalize()}", file=sys.stderr)
            print("", file=sys.stderr)
            print(f"   Found {len(violations)} violation(s):", file=sys.stderr)
            print("", file=sys.stderr)

            for i, violation in enumerate(violations, 1):
                print(f"   {i}. Line {violation['line']}: {violation['message']}", file=sys.stderr)
                print(f"      Code: {violation['code']}", file=sys.stderr)
                print(f"      Rule: {violation['rule']}", file=sys.stderr)
                print(f"      Fix: {violation['fix']}", file=sys.stderr)
                print("", file=sys.stderr)

            print(f"   Summary: {len(violations)} violation(s) must be fixed before proceeding.", file=sys.stderr)
            print("", file=sys.stderr)
            print("   Learn more:", file=sys.stderr)
            print("     https://atomicdesign.bradfrost.com/chapter-2/", file=sys.stderr)
            print(f"     {level.capitalize()} should be {'presentational' if level == 'atoms' else 'simple' if level == 'molecules' else 'layout-only' if level == 'templates' else 'feature-focused'}", file=sys.stderr)
            print("", file=sys.stderr)

            sys.exit(2)

        # No violations found
        sys.exit(0)

    except Exception as e:
        print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(0)

if __name__ == '__main__':
    main()
