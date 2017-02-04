#!/bin/bash
cp Makefile Makefile-unpatched
sed -e 's|\.\.\/open-zwave\/|/srv/hass/python-openzwave/openzwave/|' \
    -e 's|LIBMICROHTTPD := .*$|LIBMICROHTTPD := /usr/local/lib/libmicrohttpd.a|' \
    <Makefile >Makefile

