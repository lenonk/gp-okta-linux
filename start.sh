#!/usr/bin/env bash

# Tested on Xubuntu 19.10 and CentOS 8

set -e

# make sure script is not running as root
if [ $(id -u) = 0 ]; then
    >&2 echo "Script should not be run as root (openconnect will ask though)"
    exit 1
fi

GP_OKTA_CONF=gp-okta.conf
GP_OKTA_CONF_DIR=${HOME}/.local/etc

GP_SAML_GUI=gp-saml-gui
GP_SAML_GUI_DIR=${HOME}/.local/opt/gp-saml-gui

HIPREPORT_DIR=${HOME}/.config/gp-saml-gui
HIPREPORT_SCRIPT=hipreport.sh

# make sure we have gp-okta.conf
if [[ ! -f ${GP_OKTA_CONF_DIR}/${GP_OKTA_CONF} ]]; then
    >&2 echo "Please setup /etc/gp-okta.conf to contain VPN_SERVER"
    exit 1
fi

# make sure we have gp-saml-gui.py
if [[ ! -f ${GP_SAML_GUI_DIR}/gp_saml_gui.py ]]; then
    >&2 echo "Installation incomplete. Please install gp-saml-gui."
    exit 1
fi

source ${GP_OKTA_CONF_DIR}/${GP_OKTA_CONF}

if [[ "${VPN_SERVER}" = "" ]]; then
    >&2 echo "Please setup ${GP_OKTA_CONF_DIR}/${GP_OKTA_CONF} to contain VPN_SERVER"
    exit 1
fi

# start
eval $( ${GP_SAML_GUI_DIR}/gp_saml_gui.py --no-verify "${VPN_SERVER}" )
if [ -z "${COOKIE}" ] || [ -z "${HOST}" ]; then
    >&2 echo "\$HOST or \$COOKIE is not set."
    echo "Host: ${HOST}"
    echo "Cookie: ${COOKIE}"
fi

echo "${COOKIE}" | pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY openconnect \
    --protocol=gp \
    --user="${USER}" \
    --usergroup=gateway:prelogin-cookie \
    --os=win \
    --csd-wrapper=${HIPREPORT_DIR}/${HIPREPORT_SCRIPT} \
    --servercert=pin-sha256:/rrT9MQ8Bq6QejYL6qDSr6kUt1RXcpkl8LaizKSvGiI= \
    --passwd-on-stdin \
    --disable-ipv6 \
    --background \
    --pid-file=/tmp/gp-okta.pid \
    "${HOST}"
