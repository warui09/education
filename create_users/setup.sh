#!/bin/bash
# =============================================================================
# ShuleHQ - Site Setup Script
# =============================================================================
# Run this ONCE after bench init, get-app, and new-site are complete.
# Handles infrastructure setup.
#
# Usage:
#   chmod +x shulehq-setup.sh
#   ./shulehq-setup.sh
#
# After this script, create users.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shulehq-config.sh"
validate_config

cd "$BENCH_DIR"

echo ""
echo "======================================================"
echo " ShuleHQ Site Setup"
echo "======================================================"

# -----------------------------------------------------------------------------
# STEP 1: Install apps
# -----------------------------------------------------------------------------
echo ""
echo "[1/4] Installing apps..."

bench --site "$SITE" install-app erpnext
bench --site "$SITE" install-app education
bench --site "$SITE" install-app hrms

echo "✓ Apps installed"

# -----------------------------------------------------------------------------
# STEP 2: Enable developer mode
# -----------------------------------------------------------------------------
echo ""
echo "[2/4] Enabling developer mode..."

bench --site "$SITE" set-config developer_mode 1

echo "✓ Developer mode enabled"

# -----------------------------------------------------------------------------
# STEP 3: Hide irrelevant workspaces
# -----------------------------------------------------------------------------
# In Frappe v15, the sidebar is driven entirely by Workspaces.
# block_modules and Module Profile are cosmetic — they do not reliably
# hide modules. The only reliable mechanism is:
#   1. is_hidden = 1 on Workspace (hides from sidebar globally)
#   2. Role permissions (controls actual data access)
#
# These workspaces are hidden because they have no relevance to a school.
# Administrator can still access everything via URL or Ctrl+G search.
# -----------------------------------------------------------------------------
echo ""
echo "[3/4] Hiding irrelevant workspaces..."

run_query "
UPDATE \`tabWorkspace\`
SET is_hidden = 1
WHERE name IN (
  'Manufacturing',
  'Selling',
  'CRM',
  'Support',
  'Website',
  'ERPNext Integrations',
  'Quality',
  'Build',
  'Tools',
  'Integrations',
  'ERPNext Settings'
);
"

echo "✓ Workspaces configured"
echo ""
echo "  Visible workspaces:"
run_query "
SELECT name, module
FROM \`tabWorkspace\`
WHERE is_hidden = 0
ORDER BY module;
"

# -----------------------------------------------------------------------------
# STEP 4: Clear cache
# -----------------------------------------------------------------------------
echo ""
echo "[4/4] Clearing cache..."

bench --site "$SITE" clear-cache
bench --site "$SITE" clear-website-cache

echo "✓ Cache cleared"

# -----------------------------------------------------------------------------
# DONE
# -----------------------------------------------------------------------------
echo ""
echo "======================================================"
echo " Setup Complete!"
echo "======================================================"
echo ""
echo " Site: http://$SITE:8000"
echo " Run:  bench start"
echo ""
echo " Now create your users:"
echo "   ./create-school-head.sh"
echo "   ./create-teacher.sh"
echo "   ./create-bursar.sh"
echo "   ./create-student.sh"
echo "   ./create-guardian.sh"
echo ""
echo " Role reference:"
echo "   School Head → Academics Manager, HR Manager, Accounts Manager"
echo "   Teacher     → Academics User, Educator"
echo "   Bursar      → Accounts User, Accounts Manager, Academics User"
echo "   Student     → Student (Website User, portal only)"
echo "   Guardian    → Guardian (Website User, portal only)"
echo ""