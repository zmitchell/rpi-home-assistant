docker run -d --name hass --net=host -v /etc/localtime:/etc/localtime:ro -v /home/pi/hass/config:/config zmitchell/rpi-home-assistant:latest
