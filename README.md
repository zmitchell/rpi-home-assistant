# Intro
The scripts in this repo will let you build and run a Docker image to run Home Assistant on a Raspberry Pi 3 with the openzwave package already installed. This is pretty rough around the edges, but if you find something that doesn't work, let me know and we can work on it. This is based loosely on the work done by GitHub user [lroguet](https://github.com/lroguet/rpi-home-assistant), but this setup provides Z-Wave capabilities if you have a Z-Wave USB stick. If you don't need Z-Wave capabilities, check out the scripts from [lroguet](https://github.com/lroguet/rpi-home-assistant) since they're simpler.

# User Specific Changes
This is a list of things that YOU will need to change to make this work for you. These settings tell the scripts where to find your configuration files, etc.

## `build.sh`
The only things you might need to change here are the Home Assistant dependencies (look for the line that says "Install Home Assistant dependencies"), and the Docker repository to push the image to. 

There seems to be a bug in Home Assistant that prevents it from successfully installing some packages on its own, so you have to install them *before* installing Home Assistant to prevent it from even trying to install them.

One solution to this problem would be to download the `requirements_all.txt` file from the Home Assistant repository on GitHub and install all of the dependencies from there. However, there also seems to be a bug somewhere in that process, so it was just easier for me to manually specify which packages I needed. The need to do this may change at some point in the future.

## `run.sh`

- `CONFIG`: This is the directory containing your `configuration.yaml` file.
- `ZW_STICK`: This is the location of your Z-Wave USB stick. 
    - It will probably be of the form `/dev/ttyACM*`. 
    - You can find out which device your USB stick is by running `ls /dev/ttyACM*`, removing your USB stick, and running `ls /dev/ttyACM*` again. The device that is disappears the second time you run the command is your USB stick.
- `HA_VERSION`: This is the version of Home Assistant that you want to run.
    - You can choose a specific version (i.e. 0.35.3) or "latest" (without the quotes)
- 

# `build.sh`
The `build.sh` script allows you to automate building the Docker image, tagging it, and pushing it to the Docker Hub. If you don't want to push your image to the Docker Hub, you can just comment out the section of `build.sh` that does this. 

This script generates a Dockerfile for the image and uses it to build the image. If you want to make changes to the Dockerfile, do it in `build.sh`, otherwise your changes will be overwritten the next time the image is built.

# Generated Dockerfile
There is a section in `build.sh` that looks like this:

    cat << _EOF_ > Dockerfile
    ...
    _EOF_

This is called a "heredoc." The way this works in general is that if you have the following in a `bash` script

    cat << someString > /path/to/aFile
    some text possibly spanning several lines
    someString

you're telling the shell to take everything between `cat << someString > /path/to/aFile` and the first occurrence of `someString` and stick it into the file at the location `/path/to/aFile`. This is how we generate the Dockerfile. It might seem overly complicated, but it allows us build a specific version of Home Assistant by passing it as an argument to `build.sh`, or to build the latest version by default.

# `run.sh`
There are several options that need to be passed to the `docker run` command in order for Home Assistant to work properly. For instance, the `--net=host` command lets the container communicate over your network. 
