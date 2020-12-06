#!/usr/bin/env bash

# Tested on Xubuntu 19.10 and CentOS 8

set -e

GP_OKTA_CONF=gp-okta.conf
GP_OKTA_CONF_DIR=${HOME}/.local/etc

GP_SAML_GUI=gp-saml-gui
GP_SAML_GUI_DIR=${HOME}/.local/opt/gp-saml-gui

HIPREPORT_DIR=${HOME}/.config/gp-saml-gui
HIPREPORT_SCRIPT=hipreport.sh

function install_conf {

    if [ ! -d ${GP_OKTA_CONF_DIR} ]; then
        mkdir -p ${GP_OKTA_CONF_DIR};
    fi

    if [ ! -f ${GP_OKTA_CONF_DIR}/${GP_OKTA_CONF} ]; then
        echo "export VPN_SERVER=${1}" > ${GP_OKTA_CONF_DIR}/${GP_OKTA_CONF}
    fi
}

function install_gp_saml_gui {
    if [ ! -d ${GP_SAML_GUI_DIR} ]; then
        git clone https://github.com/dlenski/${GP_SAML_GUI}.git ${GP_SAML_GUI_DIR}
    fi
}

function install_hipreport {
    # mkdir for sources, if not available
    if [ ! -d ${HIPREPORT_DIR} ]; then
        mkdir -p ${HIPREPORT_DIR}
    fi
    # download HIP report script
    if [ ! -f "${HIPREPORT_DIR}/${HIPREPORT_SCRIPT}" ]; then
        cp ${HIPREPORT_SCRIPT} ${HIPREPORT_DIR}
        chmod +x "${HIPREPORT_DIR}/${HIPREPORT_SCRIPT}"
    fi
}

# read desired VPN server here
VPN_SERVER_ATTEMPTS=3
VPN_SERVER=
if [ -f ${GP_OKTA_CONF_DIR}/${GP_OKTA_CONF} ]; then
    source ${GP_OKTA_CONF_DIR}/${GP_OKTA_CONF}
fi
while [ "" = "${VPN_SERVER}" ]; do
    read -p "VPN Server: " VPN_SERVER
    if [ "" = "${VPN_SERVER}" ]; then
        VPN_SERVER_ATTEMPTS=$(($VPN_SERVER_ATTEMPTS-1))
    fi
    if [ 0 = $VPN_SERVER_ATTEMPTS ]; then
        exit 1
    fi
done

if [ "" = "${VPN_SERVER}" ]; then
    >&2 echo "VPN Server not set. Edit ${GP_OKTA_CONF_DIR}/${GP_OKTA_CONF} before starting VPN."
fi

# ubuntu
if ! [[ $(command -v "apt") = "" ]]; then
    sudo apt update
    sudo apt -y install \
        git wget openconnect \
        python3-gi gir1.2-gtk-3.0 gir1.2-webkit2-4.0 \
        python-lxml python-requests
    install_conf "${VPN_SERVER}"
    install_hipreport
    install_gp_saml_gui
# centos
elif ! [[ $(command -v "yum") = "" ]]; then
    sudo yum -y update
    sudo yum -y install epel-release
    sudo yum -y install openconnect vpnc-script
    sudo yum -y install git
    install_conf "${VPN_SERVER}"
    install_hipreport
    install_gp_saml_gui
# arch
elif ! [[ $(command -v "pacman") = "" ]]; then
    sudo pacman -Syy --noconfirm \
        git wget openconnect \
        python-gobject webkit2gtk \
        python-lxml python-requests
    install_conf "${VPN_SERVER}"
    install_hipreport
    install_gp_saml_gui
# unknown
else
    >&2 echo "You are not running a Debian/Red Hat/Arch derivative. Sorry."
    exit 1
fi

./install_indicator.sh
./add-udev-rule.sh
