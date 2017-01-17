#!/bin/bash

HA_LATEST=false

log() {
   now=$(date +"%Y%m%d-%H%M%S")
   echo "$now - $*" >> /home/pi/rpi-home-assistant/log/docker-build.log
}

log "---------------------"

# Home Assistant version
# if [ "$1" != "" ]; then
#    # Provided as an argument
#    HA_VERSION=$1
#    log "Docker image with Home Assistant $HA_VERSION"
# else
#    _HA_VERSION="$(cat /home/pi/rpi-home-assistant/log/docker-build.version)"
#    HA_VERSION="$(curl 'https://pypi.python.org/pypi/homeassistant/json' | jq '.info.version' | tr -d '"')"
#    HA_LATEST=true
#    log "Docker image with Home Assistant 'latest' (version $HA_VERSION)" 
# fi
HA_VERSION=0.35.3


# Skip the build if the version has been built already
# if [ "$HA_LATEST" = true ] && [ "$HA_VERSION" = "$_HA_VERSION" ]; then
#    log "Docker image with Home Assistant $HA_VERSION has already been built & pushed"
#    log ">>--------------------->>"
#    exit 0
# fi

########################################################################
## Dockerfile Start
########################################################################
cat << _EOF_ > Dockerfile
FROM resin/rpi-raspbian
MAINTAINER Zach Mitchell <zmitchell@fastmail.com>

# Base layer
ENV ARCH=arm
ENV CROSS_COMPILE=/usr/bin/

# Install dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends build-essential net-tools \
    nmap python3-dev python3-pip ssh \
    cython3 libudev-dev python3-sphinx python3-setuptools git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    pip3 install --upgrade cython==0.24.1

# Building python-openzwave with a non-root user
RUN useradd -s /bin/bash zwave
RUN mkdir python-openzwave && \
    git clone https://github.com/OpenZWave/python-openzwave.git && \
    chown -R zwave python-openzwave
WORKDIR python-openzwave
USER zwave
RUN git checkout python3
RUN PYTHON_EXEC=/usr/bin/python3 make build
USER root
RUN PYTHON_EXEC=/usr/bin/python3 make install
WORKDIR /

# Mouting point for the user's configuration
VOLUME /config

# Install Home Assistant dependencies
RUN pip3 install astral==1.3.3 netdisco==0.8.1 \
    phue==0.9 python-forecastio==1.3.5

# Install Home Assistant
RUN pip3 install homeassistant==$HA_VERSION

# Start Home Assistant
CMD [ "python3", "-m", "homeassistant", "--config", "/config" ]
_EOF_
########################################################################
## Dockerfile End
########################################################################


# Build and tag the image
log "Building zmitchell/rpi-home-assistant:$HA_VERSION"
docker build -t zmitchell/rpi-home-assistant:$HA_VERSION .
if [ "$HA_LATEST" = true ]; then
   log "Tagging zmitchell/rpi-home-assistant:$HA_VERSION with latest"
   docker tag zmitchell/rpi-home-assistant:$HA_VERSION zmitchell/rpi-home-assistant:latest
   echo $HA_VERSION > /home/pi/rpi-home-assistant/log/docker-build.version
fi

# Push the image to Docker Hub
#log "Pushing zmitchell/rpi-home-assistant:$HA_VERSION"
#docker push zmitchell/rpi-home-assistant:$HA_VERSION
# if [ "$HA_LATEST" = true ]; then
#    log "Pushing zmitchell/rpi-home-assistant:latest"
#    docker push zmitchell/rpi-home-assistant:latest
# fi

log "---------------------"
