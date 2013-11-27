#!/bin/sh
## wget -O tox.sh https://gist.github.com/fr0stycl34r/6690783/raw && chmod +x ./tox.sh && ./tox.sh
# By cl34r and notadecent
rootcheck() {
  if [ "$(whoami)" = "root" ]; then
    echo "Please do not run this script as root"
    exit 1
  fi
}
# Check if script is being run as root
rootcheck
# With checkinstall
install1() {
  git clone git://github.com/jedisct1/libsodium.git
  cd libsodium
  autoreconf -if
  ./autogen.sh
  ./configure --prefix=/usr/local/
  yes "" | sudo checkinstall --install --pkgname libsodium --pkgversion 0.4.2 --nodoc
  sudo /sbin/ldconfig
  cd ..
  git clone git://github.com/irungentoo/ProjectTox-Core.git
  cd ProjectTox-Core
  autoreconf -if
  ./configure --disable-av --prefix=/usr/local/ --with-dependency-search=/usr/local/
  make
  sudo make install
  sudo /sbin/ldconfig
  cd ..
  git clone git://github.com/Tox/toxic.git
  cd toxic
  autoreconf -if
  ./configure --with-dependency-search=/usr/local/lib/
  make
  sudo make install
  sudo /sbin/ldconfig
  cd ..
}
# Without checkinstall
install2() {
  git clone git://github.com/jedisct1/libsodium.git
  cd libsodium
  git checkout tags/0.4.2
  ./autogen.sh
  ./configure --prefix=/usr/local/lib/
  make check
  make
  sudo make install
  sudo /sbin/ldconfig
  cd ..
  git clone git://github.com/irungentoo/ProjectTox-Core.git
  cd ProjectTox-Core
  autoreconf -i
  ./configure --prefix=/usr/local/lib/ --with-dependency-search=/usr/local/lib/
  make
  sudo make install
  sudo /sbin/ldconfig
  cd ..
  git clone git://github.com/Tox/toxic.git
  cd toxic
  autoreconf -if
  ./configure --with-dependency-search=/usr/local/lib/
  make
  sudo make install
  sudo /sbin/ldconfig
  cd ..
  if grep -Fxq "/usr/local/lib/" /etc/ld.so.conf.d/locallib.conf;then
    echo "/etc/ld.so.conf.d/locallib.conf found"
  else
    echo '/usr/local/lib/' | sudo tee -a /etc/ld.so.conf.d/locallib.conf
    sudo /sbin/ldconfig
  fi
}
# Temporary workaround for 'Auto-connect failed with error code 1'
mkdir -p ~/.config/tox
wget -N --directory-prefix=/home/$USER/.config/tox/ https://raw.github.com/irungentoo/ProjectTox-Core/master/other/DHTservers
get_distro_type() {
  # Fedora / RHEL / CentOS / Redhat derivative
  if [ -r /etc/yum.conf ]; then
    echo "RHEL / derivative detected"
    sudo yum localinstall --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fe	dora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo yum groupinstall "Development Tools"
    sudo yum install git-core libtool curl autoconf automake ffmpeg libconfig-devel ncurses-devel opusfile-devel opusfile libvpx libvpx-devel
    sudo rm -rf ~/bin/tox
    mkdir -p ~/bin/tox
    cd ~/bin/tox
    install2
    # SUSE
    elif [ -r /etc/SuSE-release ]; then
    echo "SuSE Linux / derivative detected"
    sudo zypper install ncurses-utils curl autoconf git ffmpeg libconfig-devel libconfig9 check libtool libavcodec55 libvpx libavdevice55 libavformat55 libswscale2 libopenal1 libSDL2-2_0-0 libopus0
    sudo zypper install --type pattern devel_basis
    sudo rm -rf ~/bin/tox
    mkdir -p ~/bin/tox
    cd ~/bin/tox
    install1
    # Debian / Ubuntu / Mint / Debian derivative
    elif [ -r /etc/apt ]; then
    echo "Debian Linux / derivative detected"
    sudo rm -rf ~/bin/tox
    mkdir -p ~/bin/tox
    cd ~/bin/tox
    wget http://www.hyperrealm.com/libconfig/libconfig-1.4.9.tar.gz >> /dev/null
    tar -xvzf libconfig-1.4.9.tar.gz >> /dev/null
    cd libconfig-1.4.9
    ./configure >> /dev/null
    make -j3 >> /dev/null
    sudo make install >> /dev/null
    sudo apt-get install git curl build-essential libtool autotools-dev automake ncurses-dev checkinstall libavformat-dev libavdevice-dev libswscale-dev libsdl-dev libopenal-dev libopus-dev qt5-qmake libvpx-dev check
    cd ..
    rm ./libconfig-1.4.9.tar.gz
    git clone git://source.ffmpeg.org/ffmpeg.git
    cd ffmpeg
    git checkout n2.0.2
    ./configure --prefix=`pwd`/install --disable-programs
    make && make install
    cd ..
   install1
    # Gentoo / Gentoo derivative
    elif [ -r /etc/gentoo-release ]; then
    echo "Gentoo Linux / derivative detected"
    echo "If you run into problems with this script, refer to http://wiki.gentoo.org/wiki/Layman and report the problems to me."
    sudo emerge dev-vcs/git layman
    sudo layman -f -o https://raw.github.com/fr0stycl34r/gentoo-overlay-tox/master/repository.xml -a tox-overlay
    sudo layman -S
    sudo emerge --sync
    sudo emerge --autounmask-write virtual/ffmpeg
    sudo emerge --autounmask-write dev-libs/libsodium
    sudo emerge --autounmask-write net-libs/tox
    sudo emerge --autounmask-write net-im/toxic
    sudo echo u | sudo dispatch-conf
    sudo emerge virtual/ffmpeg
    sudo emerge dev-libs/libsodium
    sudo emerge net-libs/tox
    sudo emerge net-im/toxic
    # Arch / Arch derivative
    elif [ -r /etc/pacman.d/ ]; then
    echo "Arch Linux / derivative detected"
    sudo pacman -Syy ncurses libconfig qt5-base git curl openal opus libvpx sdl libvorbis ffmpeg
    sudo pacman -S base-devel
    sudo rm -rf ~/bin/tox
    mkdir -p ~/bin/tox
    cd ~/bin/tox
    install2
    # Other
  else
    echo "Unknown distro, install manually"
  fi
}
# Detect GNU/Linux distribution/install dependencies for Tox/Toxic
get_distro_type
echo "Done"