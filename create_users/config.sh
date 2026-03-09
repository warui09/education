#!/bin/bash
# =============================================================================
# ShuleHQ - Shared Config & Helper Functions
# Sourced by all user creation scripts — edit this file only.
# =============================================================================

# -----------------------------------------------------------------------------
# SITE CONFIG — edit this file once, all scripts inherit these configs
# -----------------------------------------------------------------------------
SITE="shulehq.localhost"
BENCH_DIR="$HOME/frappe/shulehq-bench"
DB_ROOT_PASS=""         # mariadb root password
                        # TODO: this should come from environment variable
                        #       or command line argument

DB_NAME=""              # from: mariadb -u root -p -e "SHOW DATABASES;"
                        # frappe hashes the db name so there is need to check
                        # and record this
                        # for security purposes this could also be set as 
                        # an env variable

# -----------------------------------------------------------------------------
# VALIDATION
# -----------------------------------------------------------------------------
validate_config() {
  if [ -z "$DB_ROOT_PASS" ]; then
    echo "ERROR: Set DB_ROOT_PASS in config.sh before running."
    exit 1
  fi
  if [ -z "$DB_NAME" ]; then
    echo "ERROR: Set DB_NAME in shulehq-config.sh before running."
    echo "Run: mariadb -u root -p -e \"SHOW DATABASES;\""
    exit 1
  fi
  if [ ! -d "$BENCH_DIR" ]; then
    echo "ERROR: Bench directory not found at $BENCH_DIR"
    exit 1
  fi
}

# -----------------------------------------------------------------------------
# HELPERS
# -----------------------------------------------------------------------------

# Run a mariadb query
run_query() {
  mariadb -u root -p"$DB_ROOT_PASS" "$DB_NAME" -e "$1"
}

# Add a role to a user if not already assigned
add_role() {
  local USER=$1
  local ROLE=$2
  local EXISTS=$(run_query "
    SELECT COUNT(*) as count 
    FROM \`tabUser Role\` 
    WHERE parent='$USER' AND role='$ROLE';
  " | grep -v count | tr -d ' ')

  if [ "$EXISTS" = "0" ]; then
    run_query "
    INSERT INTO \`tabUser Role\` 
      (name, creation, modified, modified_by, owner, parent, parentfield, parenttype, role)
    VALUES 
      (LOWER(HEX(RANDOM_BYTES(10))), NOW(), NOW(), 'Administrator', 'Administrator', '$USER', 'roles', 'User', '$ROLE');
    "
    echo "  + Role assigned: $ROLE"
  else
    echo "  ✓ Role already exists: $ROLE"
  fi
}

# Create a user in the DB if they don't exist
# NOTE: Password must be set via UI or reset email after creation
create_user() {
  local EMAIL=$1
  local FIRST=$2
  local LAST=$3
  local USER_TYPE=${4:-"System User"}  # "System User" or "Website User"

  local EXISTS=$(run_query "
    SELECT COUNT(*) as count FROM tabUser WHERE name='$EMAIL';
  " | grep -v count | tr -d ' ')

  if [ "$EXISTS" = "0" ]; then
    run_query "
    INSERT INTO tabUser 
      (name, creation, modified, modified_by, owner, email, first_name, last_name, 
       user_type, enabled, new_password, language, time_zone, send_welcome_email)
    VALUES 
      ('$EMAIL', NOW(), NOW(), 'Administrator', 'Administrator', '$EMAIL', 
       '$FIRST', '$LAST', '$USER_TYPE', 1, '', 'en', 'Africa/Nairobi', 0);
    "
    echo "  + User created: $EMAIL"
  else
    echo "  ✓ User already exists: $EMAIL"
  fi
}

# Print a summary footer
print_footer() {
  local EMAIL=$1
  local ROLE_DESC=$2
  echo ""
  echo "------------------------------------------------------"
  echo " User ready: $EMAIL"
  echo " Role:       $ROLE_DESC"
  echo ""
  echo " Set password at:"
  echo " http://$SITE:8000/app/user/$EMAIL"
  echo "------------------------------------------------------"
}