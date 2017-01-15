# Intro
The scripts in this repo will let you build and run a Docker image to run Home Assistant on a Raspberry Pi 3 with the openzwave package already installed.

# `build.sh`
The `build.sh` script allows you to automate building, pushing, and tagging the Docker image. This script generates a Dockerfile for the image and uses it to build the image. If you want to make changes to the Dockerfile, do it in `build.sh`, otherwise they will be overwritten next time the image is built.

