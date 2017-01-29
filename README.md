# Intro
The scripts in this repo will let you build and run a Docker image to run Home Assistant on a Raspberry Pi 3 with the openzwave package already installed. This is pretty rough around the edges, but if you find something that doesn't work, let me know and we can work on it. This is based loosely on the work done by GitHub user [lroguet](https://github.com/lroguet/rpi-home-assistant), but this setup provides Z-Wave capabilities if you have a Z-Wave USB stick. If you don't need Z-Wave capabilities, check out the scripts from [lroguet](https://github.com/lroguet/rpi-home-assistant) since they're simpler.

# User Specific Changes
This is a list of things that YOU will need to change to make this work for you. These settings tell the scripts where to find your configuration files, etc.

## `build.sh`
The only thing you would want to change here would be the Docker repository to push your image to once it's built. You can't push to my repository :)

## `run.sh`

- `CONFIG`: This is the directory containing your `configuration.yaml` file.
- `ZW_STICK`: This is the location of your Z-Wave USB stick. 
    - It will probably be of the form `/dev/ttyACM*`. 
    - You can find out which device your USB stick is by running `ls /dev/ttyACM*`, removing your USB stick, and running `ls /dev/ttyACM*` again. The device that disappears the second time you run the command is your USB stick.
- `HA_VERSION`: This is the version of Home Assistant that you want to run.
    - You can choose a specific version (i.e. 0.35.3) or "latest" (without the quotes)

The location of the Z-Wave stick is needed here because it will get set to `/dev/zwave` inside the Docker container and in your configuration file (see the next step). This makes it so you only have to set the location of your USB stick in one place (`run.sh`).

## `configuration.yaml`
You'll need to add the `zwave` component to your `configuration.yaml`. Set `usb_path` to `/dev/zwave` and set the `config_path` to `/srv/hass/python-openzwave/openzwave/config` since that's where it gets installed in the Docker container. 

    zwave:
        usb_path: /dev/zwave
        config_path: /srv/hass/python-openzwave/openzwave/config

# Documentation

## `build.sh`
The `build.sh` script allows you to automate building the Docker image, tagging it, and pushing it to the Docker Hub. If you don't want to push your image to the Docker Hub, you can just comment out the section of `build.sh` that does this. 

This script generates a Dockerfile for the image and uses it to build the image. If you want to make changes to the Dockerfile, do it in `build.sh`, otherwise your changes will be overwritten the next time the image is built.

## Making the Dockerfile
There is a section in `build.sh` that looks like this:

    cat << _EOF_ > Dockerfile
    ...
    _EOF_

This is called a "heredoc." The way this works in general is that if you have the following in a `bash` script

    cat << someString > /path/to/aFile
    some text
    possibly spanning
    several lines
    someString

you're telling the shell to take everything between the first line, `cat << someString > /path/to/aFile`, and the first occurrence of `someString` and stick that stuff into a file at the location `/path/to/aFile`. This is how we generate the Dockerfile. 

Having the template for the Dockerfile embedded in `build.sh` isn't pretty or ideal, but it gets the job done. This method allows us to dynamically generate a Dockerfile so that we can automate the build process for new versions of Home Assistant.

## `run.sh`
There are several options that need to be passed to the `docker run` command in order for Home Assistant to work properly. This script is just an easy way to call `docker run` with all of the necessary options without having to type them out every single time.
