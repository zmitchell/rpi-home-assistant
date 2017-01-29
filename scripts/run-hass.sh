#!/bin/bash
. /srv/hass/hass-venv/bin/activate
python3 -m homeassistant --config /srv/hass/config
