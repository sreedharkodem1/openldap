FROM alpine:3.19

LABEL MAINTAINER devopsarchitect2021@gmail.com

## Add Forward proxy Arguments to build-arg if the environment is internet restricted
ARG HTTP_PROXY HTTPS_PROXY

# Set environment variables
ENV LDAP_DOMAIN="example.com"
ENV LDAP_DC="dc=ldap,dc=example,dc=com"
ENV LDAP_ADMIN_PASSWORD="admin"
ENV LDAP_ADMIN_USER="admin"
ENV USE_TLS="false"
ENV LDAP_PORT=1389
ENV LDAP_PORT_TLS=1636
ENV START_ONLY_TLS="false"
ENV SLAPD_CONF="/etc/openldap/slapd.conf"

COPY scripts/ /scripts/
COPY config/ /config/
COPY ldifs/ /ldifs/


### Install ldap packages
RUN  apk update \
  && apk add gettext openssl openldap openldap-back-mdb openldap-clients \
  && rm -rf /var/cache/apk/* \
  && mkdir -p /var/lib/openldap/openldap-data \
  && chmod 700 /var/lib/openldap/openldap-data \
  && chmod 755 /scripts/* \
  && mkdir /etc/openldap/slapd.d 

RUN sh /scripts/ldap_install_list.sh

ENTRYPOINT [ "sh","/scripts/docker-entrypoint.sh" ]





