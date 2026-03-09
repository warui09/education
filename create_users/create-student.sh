#!/bin/bash
# =============================================================================
# ShuleHQ - Create Student User
# -----------------------------------------------------------------------------
# Student portal access. Can view:
#   - Their own timetable
#   - Their own attendance
#   - Their own results and assessments
#   - Fee statements (read only)
# Cannot access any staff-facing modules.
# Uses "Website User" type — portal only, no desk access.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shulehq-config.sh"
validate_config

# -----------------------------------------------------------------------------
# USER DETAILS — edit before running
# -----------------------------------------------------------------------------
EMAIL="student@example.com"
FIRST_NAME="Example-First-Name"
LAST_NAME="Example-Last-Name"

# -----------------------------------------------------------------------------
# ROLES
# Student  → portal access to own records only
# All      → mandatory base role
#
# NOTE: Website User type means no access to the Frappe desk at all.
# They only see the portal at http://shulehq.localhost/student or relevant
# url string after deployment
# -----------------------------------------------------------------------------

echo ""
echo "======================================================"
echo " Creating Student: $FIRST_NAME $LAST_NAME"
echo "======================================================"

cd "$BENCH_DIR"

# Students are Website Users — portal only, no desk
create_user "$EMAIL" "$FIRST_NAME" "$LAST_NAME" "Website User"

echo ""
echo "Assigning roles..."
add_role "$EMAIL" "All"
add_role "$EMAIL" "Student"

bench --site "$SITE" clear-cache

print_footer "$EMAIL" "Student (portal access only)"

echo ""
echo " NOTE: This is a Website User."
echo " Students access the portal at:"
echo " http://$SITE/student"
echo " They cannot log into the Frappe desk."