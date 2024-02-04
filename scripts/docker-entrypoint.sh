#!/bin/bash

LOG_LEVEL="${LOG_LEVEL:-128}"
# Check TLS configuration
cd /scripts/

echo "Check TLS configuration"
sh ./pre_ldap_tls.sh
if [ $? -ne 0 ]; then
  echo "TLS check failed. Exiting."
  exit 1
fi

echo "Check SLAPD modifications"
sh ./pre_modify_slapd.sh
if [ $? -ne 0 ]; then
  echo "slapd modication failed"
  exit 1
fi

echo "Load ldifs"
sh ./pre_load_ldifs.sh
if [ $? -ne 0 ]; then
  echo "Overlay installation failed. Exiting."
  exit 1
fi

slaptest -f $SLAPD_CONF -F /etc/openldap/slapd.d

echo "Starting OpenLDAP..."
slapd -d ${LOG_LEVEL}

