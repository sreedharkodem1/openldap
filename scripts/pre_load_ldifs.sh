#!/bin/bash

# Configuration variables
LDIF_DIR="${LDIF_DIR:-/ldifs}"

# Load LDIF files if any exist in LDIF_DIR
if [ -d "$LDIF_DIR" ] && [ "$(ls -A $LDIF_DIR)" ]; then
    for ldif_file in "$LDIF_DIR"/*.ldif; do
        if [ -f "$ldif_file" ]; then
            echo "Loading LDIF file: $ldif_file"
#            ldapadd -x -D "$LDAP_ROOT_DN" -w "$LDAP_ROOT_PW" -f "$ldif_file"
            slapadd -f /etc/openldap/slapd.conf -l $ldif_file
        fi
    done
else
    echo "No LDIF files found in $LDIF_DIR."
fi
