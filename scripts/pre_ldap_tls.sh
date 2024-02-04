#!/bin/bash

# Default values for environment variables
USE_TLS="${USE_TLS:-false}" # Whether to use TLS
GENERATE_CERTS="${GENERATE_CERTS:-false}" # Whether to generate certs
CERT_DIR="/etc/openldap/ssl"
CERT_PATH="${CERT_PATH:-$CERT_DIR/ldapserver.crt}" # Path to server certificate
KEY_PATH="${KEY_PATH:-$CERT_DIR/ldapserver.key}" # Path to private key
CA_CERT_PATH="${CA_CERT_PATH:-$CERT_DIR/ca.crt}" # Path to CA certificate



# Function to generate certificates
generate_certs() {
    # Create directory for certificates
    mkdir -p "$CERT_DIR"
    cd "$CERT_DIR"

    # Step 1: Generate CA
    openssl genpkey -algorithm RSA -out ca.key -pkeyopt rsa_keygen_bits:4096
    openssl req -x509 -new -nodes -key ca.key -sha256 -days 1024 -out ca.crt \
        -subj "/C=US/ST=YourState/L=YourCity/O=YourOrganization/OU=YourUnit/CN=$LDAP_DOMAIN"

    # Step 2: Generate LDAP Server Key and CSR
    openssl genpkey -algorithm RSA -out ldapserver.key -pkeyopt rsa_keygen_bits:4096
    openssl req -new -key ldapserver.key -out ldapserver.csr \
        -subj "/C=US/ST=YourState/L=YourCity/O=YourOrganization/OU=YourUnit/CN=$LDAP_DOMAIN"

    # Step 3: Create config for extensions
    cat >ldap_cert.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $LDAP_DOMAIN
EOF

    # Step 4: Generate signed server certificate
    openssl x509 -req -in ldapserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
        -out ldapserver.crt -days 1024 -sha256 -extfile ldap_cert.ext

    # Optional: Verify the certificate
    openssl verify -CAfile ca.crt ldapserver.crt

    echo "TLS certificates generated successfully."
}

# Function to update slapd.conf with TLS settings
update_slapd_conf_for_tls() {
    echo "Updating slapd.conf with TLS settings..."
    sed -i "s|^TLSCertificateFile.*|TLSCertificateFile $CERT_PATH|" "$SLAPD_CONF"
    sed -i "s|^TLSCertificateKeyFile.*|TLSCertificateKeyFile $KEY_PATH|" "$SLAPD_CONF"
    sed -i "s|^TLSCACertificateFile.*|TLSCACertificateFile $CA_CERT_PATH|" "$SLAPD_CONF"
    echo "slapd.conf has been updated."
}


# Main logic
if [ "$USE_TLS" == "true" ]; then
    echo "TLS is enabled."
    if [ "$GENERATE_CERTS" == "true" ]; then
        generate_certs
        update_slapd_conf_for_tls # Update slapd.conf after generating certs
    else
        # Check for the existence of specified certificate and key files
        if [ -f "$CERT_PATH" ] && [ -f "$KEY_PATH" ] && [ -f "$CA_CERT_PATH" ]; then
            echo "Using existing certificates at specified paths."
            update_slapd_conf_for_tls # Update slapd.conf with specified paths
        else
            echo "Error: Certificate, key, or CA certificate file not found at specified paths."
            exit 1
        fi
    fi
else
    echo "TLS is not enabled. Skipping certificate checks and slapd.conf update."
fi