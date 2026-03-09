#!/bin/bash
# =============================================================================
# ShuleHQ - Create Guardian (Parent) User
# -----------------------------------------------------------------------------
# Parent/guardian portal access. Can view:
#   - Their child's attendance
#   - Their child's results
#   - Fee statements and payment history
#   - School notices and communications
# Cannot access any staff-facing modules or other students' data.
# Uses "Website User" type — portal only, no desk access.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shulehq-config.sh"
validate_config

# -----------------------------------------------------------------------------
# USER DETAILS — edit before running
# -----------------------------------------------------------------------------
EMAIL="parent@example.com"
FIRST_NAME="Example-First-Name"
LAST_NAME="Example-Last-Name"

# -----------------------------------------------------------------------------
# ROLES
# Guardian → portal access to their child's records only
# All      → mandatory base role
#
# NOTE: Website User type means no access to the Frappe desk at all.
# They only see the portal at http://shulehq.localhost/parents
# or relevant url after deployment
# -----------------------------------------------------------------------------

echo ""
echo "======================================================"
echo " Creating Guardian: $FIRST_NAME $LAST_NAME"
echo "======================================================"

cd "$BENCH_DIR"

# Guardians are Website Users — portal only, no desk
create_user "$EMAIL" "$FIRST_NAME" "$LAST_NAME" "Website User"

echo ""
echo "Assigning roles..."
add_role "$EMAIL" "All"
add_role "$EMAIL" "Guardian"

bench --site "$SITE" clear-cache

print_footer "$EMAIL" "Guardian/Parent (portal access only)"

echo ""
echo " NOTE: This is a Website User."
echo " Guardians access the portal at:"
echo " http://$SITE/parents"
echo " They cannot log into the Frappe desk."
echo ""
echo " After creating this user, link them to a Student record at:"
echo " http://$SITE:8000/app/guardian/$EMAIL"