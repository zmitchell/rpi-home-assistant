#!/bin/bash

CONFIG=/home/pi/homeassistant-config
ZW_STICK=/dev/ttyACM0
HA_VERSION=0.35.3 # alternatively, use "latest"
IMAGE=zmitchell/rpi-home-assistant:$HA_VERSION

# Use the first line instead to show HA log output and remove the
# container once it exits.

docker run --rm --name hass \
    --net=host \
    -v /etc/localtime:/etc/localtime:ro \
    -v $CONFIG:/srv/hass/config \
    --device $ZW_STICK:/dev/zwave \
    $IMAGE
#docker run -d --name hass \
#    --net=host \
#    -v /etc/localtime:/etc/localtime:ro \
#    -v $CONFIG:/srv/hass/config \
#    --device $ZW_STICK:/dev/zwave \
#    $IMAGE
