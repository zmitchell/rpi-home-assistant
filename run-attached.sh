#!/bin/bash

CONFIG=/home/pi/homeassistant-config
ZW_STICK=/dev/ttyACM0
HA_VERSION=latest
IMAGE=zmitchell/rpi-home-assistant:$HA_VERSION

# Use the first line instead to show HA log output and remove the
# container once it exits.

docker run --rm --name hass-temp \
    --net=host \
    -v /etc/localtime:/etc/localtime:ro \
    -v $CONFIG:/srv/hass/config \
    -v /etc/letsencrypt:/etc/letsencrypt \
    -v /var/lib/letsencrypt:/var/lib/letsencrypt \
    --device $ZW_STICK:/dev/zwave \
    $IMAGE
