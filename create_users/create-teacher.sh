#!/bin/bash
# =============================================================================
# ShuleHQ - Create Teacher User
# -----------------------------------------------------------------------------
# Teaching staff. Can manage:
#   - Their own classes, attendance, assessments
#   - Student records (read)
#   - Cannot access finance, HR, or procurement
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shulehq-config.sh"
validate_config

# -----------------------------------------------------------------------------
# USER DETAILS — edit before running
# -----------------------------------------------------------------------------
EMAIL="teacher@example.com"
FIRST_NAME="Example-First-Name"
LAST_NAME="Example-Last-Name"

# -----------------------------------------------------------------------------
# ROLES
# Academics User  → basic education access (view students, courses)
# Educator        → mark attendance, assessments, assignments
# All             → mandatory base role
# -----------------------------------------------------------------------------

echo ""
echo "======================================================"
echo " Creating Teacher: $FIRST_NAME $LAST_NAME"
echo "======================================================"

cd "$BENCH_DIR"

create_user "$EMAIL" "$FIRST_NAME" "$LAST_NAME" "System User"

echo ""
echo "Assigning roles..."
add_role "$EMAIL" "All"
add_role "$EMAIL" "Academics User"
add_role "$EMAIL" "Educator"

bench --site "$SITE" clear-cache

print_footer "$EMAIL" "Teacher (Education module only)"