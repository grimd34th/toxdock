# ProjectTox-Core and Toxic
# https://github.com/irungentoo/ProjectTox-Core/
# https://github.com/Tox/toxic

FROM ubuntu:precise
MAINTAINER Trevor Driscoll

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list && \
        apt-get update && \
        apt-get upgrade

# Ensure UTF-8
RUN apt-get update
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

# Install
RUN apt-get install -y git \
 curl build-essential libtool autotools-dev automake ncurses-dev checkinstall libavformat-dev \
 libavdevice-dev libswscale-dev libsdl-dev libopenal-dev libvpx-dev check

ADD start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]
