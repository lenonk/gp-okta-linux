#!/usr/bin/env bash

# Tested on Xubuntu 19.10 and CentOS 8

set -e

if [ -f /tmp/gp-okta.pid ]; then
#    pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY kill "$(cat /var/run/gp-okta.pid)"
    env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY kill "$(cat /tmp/gp-okta.pid)"
fi
