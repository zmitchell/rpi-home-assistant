#!/bin/bash

# supply the image id as an argument to the script

CONFIG=/home/pi/homeassistant-config
ZW_STICK=/dev/ttyACM0

docker run -it --rm --name hass-temp \
    --net=host \
    -v /etc/localtime:/etc/localtime:ro \
    -v $CONFIG:/srv/hass/config \
    -v /etc/letsencrypt:/etc/letsencrypt \
    -v /var/lib/letsencrypt:/var/lib/letsencrypt \
    --device $ZW_STICK:/dev/zwave \
    $1 /bin/sh
