#!/usr/bin/env bash

# Tested on Xubuntu 19.10

set -e

#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INDICATOR_DIR=${HOME}/.local/opt
INDICATOR=indicator.py

START_SCRIPT=start.sh
STOP_SCRIPT=stop.sh

function install_indicator {
    if [ ! -d ${INDICATOR_DIR} ]; then
        mkdir -p ${INDICATOR_DIR}
    fi
    
    cp ${INDICATOR} ${INDICATOR_DIR}
    cp ${START_SCRIPT} ${INDICATOR_DIR}
    cp ${STOP_SCRIPT} ${INDICATOR_DIR}
}

function create_desktop_file {
    if [ -d "${1}" ]; then
        desktop="${1}/gp-okta.desktop"
        echo "[Desktop Entry]" > "${desktop}"
        echo "Encoding=UTF-8" >> "${desktop}"
        echo "Name=GlobalProtect Okta 2FA" >> "${desktop}"
        echo "GenericName=gp-okta" >> "${desktop}"
        echo "Comment=GlobalProtect Okta 2FA Indicator App" >> "${desktop}"
        echo "Terminal=false" >> "${desktop}"
        echo "Type=Application" >> "${desktop}"
        echo "Categories=" >> "${desktop}"
        #echo "Exec=bash -c 'cd ${DIR} && ./indicator.py'" >> "${desktop}"
        echo "Exec=bash -c '${INDICATOR_DIR}/${INDICATOR}'" >> "${desktop}"
        echo "Icon=${DIR}/icons/connected.svg" >> "${desktop}"
    fi
}

install_indicator

autostart_dir="${HOME}/.config/autostart"

if ! [ -d "${autostart_dir}" ]; then
    mkdir -p "${autostart_dir}" > /dev/null 2>&1
fi

create_desktop_file "${autostart_dir}"
setsid "${INDICATOR_DIR}/${INDICATOR}" &
