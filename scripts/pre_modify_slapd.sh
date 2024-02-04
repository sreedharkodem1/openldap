#!/bin/bash

# Configuration variables
LDAP_DC="dc=example,dc=com"
LDAP_ROOT_PW="${LDAP_ADMIN_PASSWORD}"
LDAP_ROOT_DN="cn=${LDAP_ADMIN_USER},${LDAP_DC}"

# Function to generate a hashed password
hash_password() {
    echo "Hashing the LDAP root password..."
    # Generate a hashed password using slappasswd
    # Note: -s flag is for the password input. Adjust the hashing algorithm as needed.
    HASHED_PW=$(slappasswd -s "$LDAP_ROOT_PW")
    echo "Password hashed."
    # Update slapd.conf with the hashed password
    echo "Updating slapd.conf with the new hashed password..."
    sed -i "s|^rootpw.*|rootpw \t\t$HASHED_PW|" "$SLAPD_CONF"
    echo "slapd.conf updated with the hashed password."
}
hash_password
# Modify slapd.conf with sed for DN changes
sed -i "s/^suffix.*/suffix \t\t\"$LDAP_DC\"/" $SLAPD_CONF
sed -i "s/^rootdn.*/rootdn \t\t\"$LDAP_ROOT_DN\"/" $SLAPD_CONF

if ! grep -q 'include /etc/openldap/slapd.d' "$SLAPD_CONF"; then
#  echo 'include /etc/openldap/slapd.d/*' >> "$SLAPD_CONF"
echo test
fi

echo "slapd modify finished"

