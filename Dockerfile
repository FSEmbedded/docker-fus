FROM ubuntu:22.04
LABEL org.opencontainers.image.authors="F&S Elektronik Systeme <support@fs-net.de>"

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y sudo openssl apt-utils git xmlstarlet

# Install basic yocto dependencies
RUN apt-get -y install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat cpio python2 python3 python3-pip python3-pexpect python-is-python3 xz-utils debianutils iputils-ping libsdl1.2-dev xterm curl lz4 zstd libarchive-zip-perl rsync bc xxd
# additional packages
# for yocto 5.0.x
RUN apt-get -y install libgnutls28-dev nano

# Install basic Buildroot dependencies
RUN apt-get -y install file sed make binutils diffutils gcc g++ bash patch gzip bzip2 tar cpio unzip rsync findutils

# Set up locales
RUN apt-get install -y locales && dpkg-reconfigure locales --frontend noninteractive && locale-gen "en_US.UTF-8" && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN apt-get update && apt-get dist-upgrade -y
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Replace dash with bash
RUN rm /bin/sh && ln -s bash /bin/sh

