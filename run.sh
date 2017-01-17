docker run --name hass --net=host -v /etc/localtime:/etc/localtime:ro -v /home/pi/hass/config:/config --device /dev/ttyACM0:/dev/zwave --rm zmitchell/rpi-home-assistant:0.35.3
