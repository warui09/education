#!/bin/bash
# =============================================================================
# ShuleHQ - Create Bursar User
# -----------------------------------------------------------------------------
# Finance staff. Can manage:
#   - Fee invoices and payments
#   - Bank reconciliation
#   - Financial reports
#   - Student fee records (read)
#   - Cannot access HR, payroll, or procurement
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shulehq-config.sh"
validate_config

# -----------------------------------------------------------------------------
# USER DETAILS — edit before running
# -----------------------------------------------------------------------------
EMAIL="bursar@example.com"
FIRST_NAME="Example-First-Name"
LAST_NAME="Example-Last-Name"

# -----------------------------------------------------------------------------
# ROLES
# Accounts User    → read access to accounts, can create invoices
# Accounts Manager → full accounts access including bank reconciliation
# Academics User   → read access to student records for fee matching
# All              → mandatory base role
# -----------------------------------------------------------------------------

echo ""
echo "======================================================"
echo " Creating Bursar: $FIRST_NAME $LAST_NAME"
echo "======================================================"

cd "$BENCH_DIR"

create_user "$EMAIL" "$FIRST_NAME" "$LAST_NAME" "System User"

echo ""
echo "Assigning roles..."
add_role "$EMAIL" "All"
add_role "$EMAIL" "Accounts User"
add_role "$EMAIL" "Accounts Manager"
add_role "$EMAIL" "Academics User"

bench --site "$SITE" clear-cache

print_footer "$EMAIL" "Bursar (Accounts + read Education)"