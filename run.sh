#!/bin/bash

CONFIG=/home/pi/hass/config
ZW_STICK=/dev/ttyACM0
HA_VERSION=0.35.3 # alternatively, use "latest"
IMAGE=zmitchell/rpi-home-assistant:$HA_VERSION

docker run --name hass \
    --net=host \
    -v /etc/localtime:/etc/localtime:ro \
    -v $CONFIG:/srv/hass/config \
    --device $ZW_STICK:/dev/zwave --rm \
    $IMAGE
