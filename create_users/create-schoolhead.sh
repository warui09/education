#!/bin/bash
# =============================================================================
# ShuleHQ - Create School Head User
# -----------------------------------------------------------------------------
# The school owner. Sees everything operational:
# Education, HR, Payroll, Accounts, Buying, Stock.
# Cannot access system configuration (that's IT Admin only).
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shulehq-config.sh"
validate_config

# -----------------------------------------------------------------------------
# USER DETAILS — edit before running
# -----------------------------------------------------------------------------
EMAIL="school_head@example.com"
FIRST_NAME="Example-First-Name"
LAST_NAME="Example-Last-Name"

# -----------------------------------------------------------------------------
# ROLES
# Academics Manager  → full education module access
# HR Manager         → full HR and payroll visibility
# Accounts Manager   → full finance visibility
# Purchase Manager   → buying and procurement
# Stock Manager      → inventory and supplies
# All                → mandatory base role
# -----------------------------------------------------------------------------

echo ""
echo "======================================================"
echo " Creating School Head: $FIRST_NAME $LAST_NAME"
echo "======================================================"

cd "$BENCH_DIR"

create_user "$EMAIL" "$FIRST_NAME" "$LAST_NAME" "System User"

echo ""
echo "Assigning roles..."
add_role "$EMAIL" "All"
add_role "$EMAIL" "Academics Manager"
add_role "$EMAIL" "HR Manager"
add_role "$EMAIL" "Accounts Manager"
add_role "$EMAIL" "Purchase Manager"
add_role "$EMAIL" "Stock Manager"

bench --site "$SITE" clear-cache

print_footer "$EMAIL" "School Head (full operational view)"