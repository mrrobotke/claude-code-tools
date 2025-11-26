#!/usr/bin/env bash
# Validates test coverage for atomic components
# Templates and pages require tests while atoms and molecules get warnings
# WHY testing requirements scale with component complexity and criticality

set -euo pipefail

# Read stdin for hook input
input=$(cat)

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Only validate React component files
if [[ ! "$file_path" =~ \.(tsx|jsx)$ ]]; then
  exit 0
fi

# Skip test files themselves
if [[ "$file_path" =~ \.(test|spec)\.(tsx|jsx)$ ]]; then
  exit 0
fi

# Skip index files
if [[ "$file_path" =~ /index\.(tsx|jsx)$ ]]; then
  exit 0
fi

# Skip type definition files
if [[ "$file_path" =~ \.types\.(tsx|ts)$ ]]; then
  exit 0
fi

# Detect atomic level
atomic_level=""
if [[ "$file_path" =~ /atoms/ ]]; then
  atomic_level="atom"
elif [[ "$file_path" =~ /molecules/ ]]; then
  atomic_level="molecule"
elif [[ "$file_path" =~ /organisms/ ]]; then
  atomic_level="organism"
elif [[ "$file_path" =~ /templates/ ]]; then
  atomic_level="template"
elif [[ "$file_path" =~ /pages/ ]]; then
  atomic_level="page"
else
  # Not an atomic component
  exit 0
fi

# Construct possible test file paths
dir_path=$(dirname "$file_path")
base_name=$(basename "$file_path" .tsx)
base_name=$(basename "$base_name" .jsx)

test_file_1="${dir_path}/${base_name}.test.tsx"
test_file_2="${dir_path}/${base_name}.test.jsx"
test_file_3="${dir_path}/${base_name}.spec.tsx"
test_file_4="${dir_path}/${base_name}.spec.jsx"

# Check if any test file exists
test_exists=false
test_file=""

if [ -f "$test_file_1" ]; then
  test_exists=true
  test_file="$test_file_1"
elif [ -f "$test_file_2" ]; then
  test_exists=true
  test_file="$test_file_2"
elif [ -f "$test_file_3" ]; then
  test_exists=true
  test_file="$test_file_3"
elif [ -f "$test_file_4" ]; then
  test_exists=true
  test_file="$test_file_4"
fi

# Minimum test requirements by level
get_min_test_count() {
  case "$1" in
    atom) echo 3 ;;
    molecule) echo 4 ;;
    organism) echo 5 ;;
    template) echo 6 ;;
    page) echo 8 ;;
    *) echo 3 ;;
  esac
}

# Check test adequacy if test file exists
check_test_adequacy() {
  local test_file=$1
  local min_tests=$2

  if [ ! -f "$test_file" ]; then
    return 1
  fi

  # Count test cases (it/test blocks)
  test_count=$(grep -cE "^\s*(it|test)\s*\(" "$test_file" || echo 0)

  # Check for basic test patterns
  has_render=$(grep -q "render(" "$test_file" && echo "yes" || echo "no")
  has_expect=$(grep -q "expect(" "$test_file" && echo "yes" || echo "no")

  if [ "$test_count" -lt "$min_tests" ] || [ "$has_render" = "no" ] || [ "$has_expect" = "no" ]; then
    return 1
  fi

  return 0
}

min_tests=$(get_min_test_count "$atomic_level")

# Handle missing tests based on atomic level
if [ "$test_exists" = false ]; then
  case "$atomic_level" in
    atom|molecule|organism)
      # Warning only - don't block
      cat >&2 <<EOF

⚠️  Missing Tests

File: $file_path
Level: ${atomic_level^}

No test file found. Expected one of:
  • $test_file_1
  • $test_file_3

Recommended tests for ${atomic_level}s:
EOF

      case "$atomic_level" in
        atom)
          cat >&2 <<EOF
  1. Renders with default props
  2. Applies correct styles/variants
  3. Handles user interactions (clicks, focus)
  4. Accessible (keyboard navigation, ARIA)

Example:
  describe('Button', () => {
    it('renders with children', () => {
      render(<Button>Click me</Button>);
      expect(screen.getByRole('button')).toHaveTextContent('Click me');
    });

    it('calls onClick when clicked', async () => {
      const onClick = vi.fn();
      render(<Button onClick={onClick}>Click</Button>);
      await userEvent.click(screen.getByRole('button'));
      expect(onClick).toHaveBeenCalledTimes(1);
    });
  });
EOF
          ;;
        molecule)
          cat >&2 <<EOF
  1. Renders with default props
  2. Handles user input correctly
  3. Calls callbacks with expected data
  4. Handles edge cases (empty, error states)

Example:
  describe('SearchField', () => {
    it('calls onSearch with trimmed query', async () => {
      const onSearch = vi.fn();
      render(<SearchField onSearch={onSearch} />);
      await userEvent.type(screen.getByRole('textbox'), '  test  ');
      await userEvent.click(screen.getByRole('button', { name: 'Search' }));
      expect(onSearch).toHaveBeenCalledWith('test');
    });
  });
EOF
          ;;
        organism)
          cat >&2 <<EOF
  1. Renders all child components
  2. Coordinates component interactions
  3. Manages internal state correctly
  4. Passes callbacks to children
  5. Handles responsive behavior

Example:
  describe('AppHeader', () => {
    it('calls onSearch when search submitted', async () => {
      const onSearch = vi.fn();
      render(<AppHeader onSearch={onSearch} />);
      await userEvent.type(screen.getByRole('textbox'), 'query');
      await userEvent.click(screen.getByRole('button', { name: 'Submit' }));
      expect(onSearch).toHaveBeenCalledWith('query');
    });
  });
EOF
          ;;
      esac

      cat >&2 <<EOF

This is a warning. You can proceed, but tests are strongly recommended.

EOF
      exit 0
      ;;

    template|page)
      # Hard requirement - block
      cat >&2 <<EOF

❌ MISSING REQUIRED TESTS

File: $file_path
Level: ${atomic_level^}

${atomic_level^}s MUST have tests before being committed.

Expected test file:
  $test_file_1

Required test coverage for ${atomic_level}s (minimum $min_tests tests):
EOF

      case "$atomic_level" in
        template)
          cat >&2 <<EOF
  1. Renders without crashing
  2. Renders all regions/slots
  3. Accepts custom content in slots
  4. Maintains semantic structure
  5. Handles optional regions
  6. Responsive layout behavior

Example:
  describe('DashboardTemplate', () => {
    it('renders all regions', () => {
      render(
        <DashboardTemplate
          sidebar={<div data-testid="sidebar">Sidebar</div>}
          main={<div data-testid="main">Main</div>}
        />
      );
      expect(screen.getByTestId('sidebar')).toBeInTheDocument();
      expect(screen.getByTestId('main')).toBeInTheDocument();
    });

    it('has proper semantic structure', () => {
      render(<DashboardTemplate sidebar={<div />} main={<div />} />);
      expect(screen.getByRole('main')).toBeInTheDocument();
    });
  });
EOF
          ;;
        page)
          cat >&2 <<EOF
  1. Renders without crashing
  2. Displays loading state
  3. Displays error state
  4. Displays content when loaded
  5. Handles user interactions
  6. Navigates correctly
  7. Manages state properly
  8. Accessible throughout

Example:
  describe('DashboardPage', () => {
    it('displays loading state', () => {
      vi.mocked(fetchData).mockImplementation(() => new Promise(() => {}));
      render(<DashboardPage />);
      expect(screen.getByText('Loading...')).toBeInTheDocument();
    });

    it('displays error state', async () => {
      vi.mocked(fetchData).mockRejectedValue(new Error('Failed'));
      render(<DashboardPage />);
      await waitFor(() => {
        expect(screen.getByText(/Error/)).toBeInTheDocument();
      });
    });

    it('displays data when loaded', async () => {
      vi.mocked(fetchData).mockResolvedValue({ items: [1, 2, 3] });
      render(<DashboardPage />);
      await waitFor(() => {
        expect(screen.getByText('Items: 3')).toBeInTheDocument();
      });
    });
  });
EOF
          ;;
      esac

      cat >&2 <<EOF

Create the test file before proceeding.

Blocked: This is a hard requirement for ${atomic_level}s.

EOF

      cat <<EOF
{
  "hookSpecificOutput": {
    "permissionDecision": "deny",
    "permissionDecisionReason": "${atomic_level^}s require tests. Please create ${test_file_1} before proceeding."
  }
}
EOF
      exit 2
      ;;
  esac
fi

# Check test adequacy if file exists
if ! check_test_adequacy "$test_file" "$min_tests"; then
  cat >&2 <<EOF

⚠️  Inadequate Test Coverage

File: $file_path
Test file: $test_file
Level: ${atomic_level^}

Test file exists but may be inadequate.

Minimum requirements:
  • At least $min_tests test cases
  • At least one render() call
  • At least one expect() assertion

Please ensure comprehensive test coverage for ${atomic_level}s.

EOF
  # Warning only - don't block
  exit 0
fi

# Tests exist and appear adequate
exit 0
