FROM resin/rpi-raspbian
MAINTAINER Zach Mitchell <zmitchell@fastmail.com>

# Base layer
ENV ARCH=arm
ENV CROSS_COMPILE=/usr/bin/

# Install some packages
RUN apt-get update &&     apt-get install --no-install-recommends build-essential net-tools nmap python3-dev python3-pip ssh &&     apt-get clean &&     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Mouting point for the user's configuration
VOLUME /config

# Start Home Assistant
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]

# Install Home Assistant
RUN pip3 install homeassistant==0.35.3
