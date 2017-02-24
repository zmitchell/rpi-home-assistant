#!/bin/bash

build_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
log_dir="$build_dir"/log
build_log="$log_dir"/docker-build.log
previous_version_log="$log_dir"/previous-build.version

build_latest_version=false

if [ ! -d "$log_dir" ]; then
  mkdir "$log_dir"
fi

log() {
   now=$(date +"%Y%m%d-%H%M%S")
   echo "$now - $*" >> "$build_log"
}

log "<<---------------------"

# Determine the Home Assistant version to build
if [ "$1" != "" ]; then
   # Provided as an argument
   version_to_build=$1
   log "Building Docker image with Home Assistant $version_to_build"
else
   previous_version="$(cat "$previous_version_log")"
   version_to_build="$(curl 'https://pypi.python.org/pypi/homeassistant/json' | jq '.info.version' | tr -d '"')"
   build_latest_version=true
   log "Building Docker image with Home Assistant 'latest' (version $version_to_build)" 
fi

# Skip the build if the version has been built already
if [ "$build_latest_version" = true ] && [ "$version_to_build" = "$previous_version" ]; then
   log "Docker image with Home Assistant $version_to_build has already been built & pushed"
   log "--------------------->>"
   exit 0
fi

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
RUN rm /bin/sh && ln -s /bin/bash /bin/sh && \
    apt-get update && apt-get upgrade -y && \
    apt-get install --no-install-recommends build-essential net-tools \
    nmap python3-dev python3-pip ssh libffi-dev libssl-dev libjpeg9-dev \
    zlib1g-dev libtiff4 liblcms1-dev liblcms2-dev libwebp-dev libopenjpeg-dev \
    cython3 libudev-dev python3-sphinx python3-setuptools python3-venv git \
    libxml2-dev libxslt1-dev
RUN pip3 install virtualenv
RUN pip3 install --upgrade pip

# Make a user called "hass" with user/group IDs equivalent to the host's
# user/group IDS. Add "hass" to the "dialout" group to give it access
# to the Z-Wave stick.
RUN groupadd -r --gid 1000 hass
RUN useradd -rm --uid 1000 --gid 1000 hass
RUN usermod -a -G dialout hass

# Set up the HA directory structure
RUN mkdir -p /srv/hass
RUN chown hass:hass /srv/hass 
COPY ./patch /srv/hass/patch
COPY ./scripts /srv/hass/scripts
RUN mkdir /srv/hass/config
RUN chown -R hass:hass /srv/hass
USER hass

# Pull down the Home Assistant repository for the requirements file
WORKDIR /srv/hass
RUN git clone https://github.com/home-assistant/home-assistant.git
WORKDIR /srv/hass/home-assistant
RUN git checkout tags/$version_to_build
RUN cp requirements_all.txt ..

# Patch the requirements file
RUN cp requirements_all.txt /srv/hass/patch/requirements.txt
WORKDIR /srv/hass/patch
RUN python3 patch.py
RUN cp patched-requirements.txt ..

# Install the Home Assistant dependencies
WORKDIR /srv/hass
RUN virtualenv hass-venv && \
    . /srv/hass/hass-venv/bin/activate && \
    pip3 install --no-cache-dir pyyaml cython==0.24.1 && \
    pip3 install --no-cache-dir -r patched-requirements.txt

# Building python-openzwave with a non-root user
RUN git clone https://github.com/OpenZWave/python-openzwave.git && \
    chown -R hass python-openzwave
WORKDIR python-openzwave
RUN git checkout python3
RUN PYTHON_EXEC=/srv/hass/hass-venv/bin/python3 make build
USER root
RUN PYTHON_EXEC=/srv/hass/hass-venv/bin/python3 make install

# Setting the permissions for the Let's Encrypt directories
RUN mkdir /etc/letsencrypt /var/lib/letsencrypt
RUN chown -R hass:hass /etc/letsencrypt && \
    chown -R hass:hass /var/lib/letsencrypt
RUN chmod -R 664 /etc/letsencrypt && \
    chmod -R 664 /var/lib/letsencrypt
VOLUME /etc/letsencrypt
VOLUME /var/lib/letsencrypt

# Mouting point for the user's configuration
VOLUME /srv/hass/config

# Install Home Assistant
USER hass
RUN . /srv/hass/hass-venv/bin/activate && \
    pip3 install homeassistant==$version_to_build

# Start Home Assistant
CMD [ "/bin/bash", "/srv/hass/scripts/run-hass.sh"]
_EOF_
########################################################################
## Dockerfile End
########################################################################


# Build and tag the image
log "Building zmitchell/rpi-home-assistant:$version_to_build"
docker build -t zmitchell/rpi-home-assistant:$version_to_build .
if [ "$build_latest_version" = true ]; then
   log "Tagging zmitchell/rpi-home-assistant:$version_to_build with 'latest'"
   docker tag zmitchell/rpi-home-assistant:$version_to_build zmitchell/rpi-home-assistant:latest
   echo $version_to_build > $previous_version_log
fi

# Push the image to Docker Hub
log "Pushing zmitchell/rpi-home-assistant:$version_to_build"
docker push zmitchell/rpi-home-assistant:$version_to_build
if [ "$build_latest_version" = true ]; then
   log "Pushing zmitchell/rpi-home-assistant:latest"
   docker push zmitchell/rpi-home-assistant:latest
fi

log "--------------------->>"
