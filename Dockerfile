FROM resin/rpi-raspbian
MAINTAINER Zach Mitchell <zmitchell@fastmail.com>

# Base layer
ENV ARCH=arm
ENV CROSS_COMPILE=/usr/bin/

# Install dependencies
RUN apt-get update && apt-get upgrade -y &&     apt-get install --no-install-recommends build-essential net-tools     nmap python3-dev python3-pip ssh libffi-dev libssl-dev libjpeg9-dev     zlib1g-dev libtiff4 liblcms1-dev liblcms2-dev libwebp-dev libopenjpeg-dev     cython3 libudev-dev python3-sphinx python3-setuptools python3-venv git
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
RUN git checkout tags/0.35.3
RUN cp requirements_all.txt ..

# Patch the requirements file
RUN cp requirements_all.txt /srv/hass/patch/requirements.txt
WORKDIR /srv/hass/patch
RUN python3 patch.py
RUN cp patched-requirements.txt ..

# Install the Home Assistant dependencies
WORKDIR /srv/hass
RUN virtualenv hass-venv &&     . /srv/hass/hass-venv/bin/activate &&     pip3 install --no-cache-dir pyyaml cython==0.24.1 &&     pip3 install --no-cache-dir -r patched-requirements.txt

# Building python-openzwave with a non-root user
RUN git clone https://github.com/OpenZWave/python-openzwave.git &&     chown -R hass python-openzwave
WORKDIR python-openzwave
RUN git checkout python3
RUN PYTHON_EXEC=/srv/hass/hass-venv/bin/python3 make build
USER root
RUN PYTHON_EXEC=/srv/hass/hass-venv/bin/python3 make install

# Setting the permissions for the Let's Encrypt directories
RUN mkdir /etc/letsencrypt /var/lib/letsencrypt
RUN chown -R hass:hass /etc/letsencrypt &&     chown -R hass:hass /var/lib/letsencrypt
RUN chmod -R 664 /etc/letsencrypt &&     chmod -R 664 /var/lib/letsencrypt
VOLUME /etc/letsencrypt
VOLUME /var/lib/letsencrypt

# Mouting point for the user's configuration
VOLUME /srv/hass/config

# Install Home Assistant
USER hass
RUN . /srv/hass/hass-venv/bin/activate &&     pip3 install homeassistant==0.35.3

# Start Home Assistant
CMD [ "/bin/bash", "/srv/hass/scripts/run-hass.sh"]
