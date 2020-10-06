#!/usr/bin/env bash

# Tested on Xubuntu 19.10 and CentOS 8

set -e

# make sure script is not running as root
if [ $(id -u) = 0 ]; then
    >&2 echo "Script should not be run as root (openconnect will ask though)"
    exit 1
fi

# make sure we have /etc/gp-okta.conf
if [[ ! -f /etc/gp-okta.conf ]]; then
    >&2 echo "Please setup /etc/gp-okta.conf to contain VPN_SERVER"
    exit 1
fi

# make sure we have /opt/gp-saml-gui/gp-saml-gui.py
if [[ ! -f /opt/gp-saml-gui/gp-saml-gui.py ]]; then
    >&2 echo "Installation incomplete. Please install gp-saml-gui."
    exit 1
fi

source /etc/gp-okta.conf

if [[ "${VPN_SERVER}" = "" ]]; then
    >&2 echo "Please setup /etc/gp-okta.conf to contain VPN_SERVER"
    exit 1
fi

# start
eval $( /opt/gp-saml-gui/gp-saml-gui.py --no-verify "${VPN_SERVER}" )
if [ -z "${COOKIE}" ] || [ -z "${HOST}" ]; then
    >&2 echo "\$HOST or \$COOKIE is not set."
    echo "Host: ${HOST}"
    echo "Cookie: ${COOKIE}"
fi

#echo "${COOKIE}" | pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY openconnect \
echo "${COOKIE}" | env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY openconnect \
    --protocol=gp \
    --user="${USER}" \
    --usergroup=gateway:prelogin-cookie \
    --os=win \
    --csd-wrapper=/usr/libexec/openconnect/hipreport.sh \
    --servercert=pin-sha256:/rrT9MQ8Bq6QejYL6qDSr6kUt1RXcpkl8LaizKSvGiI= \
    --passwd-on-stdin \
    --disable-ipv6 \
    --background \
    --pid-file=/tmp/gp-okta.pid \
    "${HOST}"
