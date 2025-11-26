#!/usr/bin/env python3
"""
Validates atomic design structure and import hierarchy
Enforces strict directory placement and prevents upward imports
WHY maintaining atomic boundaries prevents design system rot
"""

import json
import os
import sys
import re
from pathlib import Path

# Atomic level definitions with allowed parent directories
ATOMIC_LEVELS = {
    'atoms': 0,
    'molecules': 1,
    'organisms': 2,
    'templates': 3,
    'pages': 4
}

# Valid parent directories for atomic components
VALID_PARENT_DIRS = [
    'design-system',
    'ui'
]

def detect_atomic_level(file_path):
    """
    Detect atomic level from file path
    Returns tuple of (level_name, level_number) or (None, None) if not atomic
    """
    path_lower = file_path.lower()

    for level_name, level_number in ATOMIC_LEVELS.items():
        pattern = f'/{level_name}/'
        if pattern in path_lower:
            return (level_name, level_number)

    return (None, None)

def validate_directory_structure(file_path):
    """
    Validate file is in correct atomic design directory structure
    Must be in src/design-system/, src/ui/, app/design-system/, or app/ui/
    """
    issues = []

    level_name, level_number = detect_atomic_level(file_path)

    # Only validate React component files
    if not (file_path.endswith('.tsx') or file_path.endswith('.jsx')):
        return []

    # Skip if not in atomic directory
    if level_name is None:
        return []

    # Check if in valid parent directory (design-system or ui)
    path_lower = file_path.lower()
    has_valid_parent = any(
        f'/{parent_dir}/{level_name}/' in path_lower
        for parent_dir in VALID_PARENT_DIRS
    )

    if not has_valid_parent:
        valid_paths = [
            f"src/design-system/{level_name}/",
            f"src/ui/{level_name}/",
            f"app/design-system/{level_name}/",
            f"app/ui/{level_name}/"
        ]

        issues.append({
            'type': 'invalid_directory',
            'message': f"Component must be in a design-system/ or ui/ directory",
            'details': f"Found in: {file_path}",
            'expected': f"Expected one of: {', '.join(valid_paths)}",
            'fix': f"Move this {level_name} to a valid atomic design directory"
        })

    return issues

def extract_imports(content):
    """
    Extract import statements from file content
    Returns list of tuples (full_import_line, imported_path)
    """
    imports = []

    # Match various import patterns
    patterns = [
        r'import\s+.*\s+from\s+["\']([^"\']+)["\']',
        r'import\s+["\']([^"\']+)["\']',
    ]

    for pattern in patterns:
        matches = re.finditer(pattern, content, re.MULTILINE)
        for match in matches:
            import_path = match.group(1)
            full_line = match.group(0)
            imports.append((full_line, import_path))

    return imports

def validate_import_hierarchy(file_path, content):
    """
    Validate that imports respect atomic hierarchy
    Lower levels cannot import from higher levels
    """
    issues = []

    current_level, current_level_num = detect_atomic_level(file_path)

    if current_level is None:
        return []

    imports = extract_imports(content)

    for full_import, import_path in imports:
        # Skip external libraries
        if not (import_path.startswith('.') or import_path.startswith('@/')):
            continue

        # Skip non-component imports (utils, types, etc.)
        if not any(ext in import_path for ext in ['.tsx', '.jsx', '/index']):
            # Check if path contains atomic level keywords
            import_level, import_level_num = detect_atomic_level(import_path)

            if import_level is None:
                continue
        else:
            import_level, import_level_num = detect_atomic_level(import_path)

        if import_level is None:
            continue

        # Check if importing from higher level (violation)
        if import_level_num > current_level_num:
            issues.append({
                'type': 'invalid_import_hierarchy',
                'message': f"{current_level.capitalize()} cannot import from {import_level}",
                'details': f"Import: {full_import}",
                'rule': f"{current_level.capitalize()} can only import from: " +
                        f"{', '.join([l for l, n in ATOMIC_LEVELS.items() if n <= current_level_num])} and external libraries",
                'fix': get_hierarchy_fix(current_level, import_level)
            })

    return issues

def get_hierarchy_fix(current_level, imported_level):
    """
    Generate specific fix recommendation for hierarchy violation
    """
    fixes = {
        ('atoms', 'molecules'): "Move the molecule's logic into the atom, or create a new molecule that uses the atom",
        ('atoms', 'organisms'): "Refactor to pass data as props instead of importing organism",
        ('atoms', 'templates'): "Atoms should never depend on templates. Invert the dependency.",
        ('atoms', 'pages'): "Atoms should never depend on pages. Invert the dependency.",
        ('molecules', 'organisms'): "Move organism logic into molecule, or create new organism combining both",
        ('molecules', 'templates'): "Molecules should not import templates. Refactor structure.",
        ('molecules', 'pages'): "Molecules should not import pages. Refactor structure.",
        ('organisms', 'templates'): "Organisms should not import templates. Use composition instead.",
        ('organisms', 'pages'): "Organisms should not import pages. Use composition instead.",
        ('templates', 'pages'): "Templates should not import pages. Pages use templates, not vice versa."
    }

    key = (current_level, imported_level)
    return fixes.get(key, f"Refactor to remove dependency from {current_level} to {imported_level}")

def main():
    try:
        tool_input = json.loads(os.environ.get('CLAUDE_TOOL_INPUT', '{}'))
        file_path = tool_input.get('file_path', '')

        if not file_path:
            sys.exit(0)

        # Validate directory structure
        directory_issues = validate_directory_structure(file_path)

        if directory_issues:
            print("", file=sys.stderr)
            print("❌ ATOMIC STRUCTURE VIOLATION", file=sys.stderr)
            print(f"   File: {file_path}", file=sys.stderr)
            print("", file=sys.stderr)

            for issue in directory_issues:
                print(f"   Issue: {issue['message']}", file=sys.stderr)
                print(f"   {issue['details']}", file=sys.stderr)
                print(f"   {issue['expected']}", file=sys.stderr)
                print(f"   Fix: {issue['fix']}", file=sys.stderr)
                print("", file=sys.stderr)

            print("   Learn more: https://atomicdesign.bradfrost.com/chapter-2/", file=sys.stderr)
            print("", file=sys.stderr)

            sys.exit(2)

        # Read file content for import validation
        if os.path.exists(file_path):
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        else:
            # File being created - use new content from tool input
            content = tool_input.get('content', '')

        # Validate import hierarchy
        import_issues = validate_import_hierarchy(file_path, content)

        if import_issues:
            print("", file=sys.stderr)
            print("❌ ATOMIC IMPORT HIERARCHY VIOLATION", file=sys.stderr)
            print(f"   File: {file_path}", file=sys.stderr)
            print("", file=sys.stderr)

            for issue in import_issues:
                print(f"   Issue: {issue['message']}", file=sys.stderr)
                print(f"   {issue['details']}", file=sys.stderr)
                print(f"   Rule: {issue['rule']}", file=sys.stderr)
                print(f"   Fix: {issue['fix']}", file=sys.stderr)
                print("", file=sys.stderr)

            print("   Atomic Hierarchy:", file=sys.stderr)
            print("     Atoms      → can import: atoms, external libs", file=sys.stderr)
            print("     Molecules  → can import: atoms, molecules, external libs", file=sys.stderr)
            print("     Organisms  → can import: atoms, molecules, organisms, external libs", file=sys.stderr)
            print("     Templates  → can import: atoms, molecules, organisms, templates, external libs", file=sys.stderr)
            print("     Pages      → can import: ALL levels", file=sys.stderr)
            print("", file=sys.stderr)
            print("   Learn more: https://atomicdesign.bradfrost.com/chapter-2/", file=sys.stderr)
            print("", file=sys.stderr)

            sys.exit(2)

        # All validations passed
        sys.exit(0)

    except Exception as e:
        print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(0)

if __name__ == '__main__':
    main()
