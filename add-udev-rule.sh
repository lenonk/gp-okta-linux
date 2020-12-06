#!/bin/bash

sudo cp 50-tun.rules /lib/udev/rules.d/
sudo udevadm control --reload-rules
