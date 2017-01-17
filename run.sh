CONFIG=/home/pi/hass/config
ZW_STICK=/dev/ttyACM0
HA_VERSION=0.35.3 # alternatively, use "latest"
IMAGE=zmitchell/rpi-home-assistant:$HA_VERSION

#docker run --name hass --net=host -v /etc/localtime:/etc/localtime:ro -v /home/pi/hass/config:/config --device /dev/ttyACM0:/dev/zwave --rm zmitchell/rpi-home-assistant:0.35.3
docker run --name hass \
    --net=host \
    -v /etc/localtime:/etc/localtime:ro \
    -v $CONFIG:/config \
    --device $ZW_STICK:/dev/zwave --rm \
    $IMAGE
