#!/bin/bash -x

# (C) 2016 Gunnar Andersson
# License: Your choice of CC-BY-4.0, MPLv2, GPLv2/3+
# License text for MPLv2 provided in root directory.

USER=vagrant
HOMEDIR=/home/$USER
LXDE_CONF=/etc/lxdm/default.conf
PROJECTDIR=/vagrant

source_dir="$PROJECTDIR/files"

[ -d "$source_dir" ]

sudo apt-get update

# LXDE, but avoid the complaints from miscfiles & dictionaries - we don't need them
sudo apt-get install -y  --fix-broken --fix-missing --no-install-recommends \
                      lxde \
                      miscfiles- \
                      dictionaries-common- \

# Browser
sudo apt-get install -y firefox

# Webex prerequisites
sudo apt-get install -y openjdk-7-jre        \
                        libxmu6              \
                        icedtea-7-plugin     \
                        libpangox-1.0-dev    \
                        libxmu-dev           \
                        libegl1-mesa-dev     \
                        libgtk2.0-dev        \
                        libpng-dev           \
                        libasound2-dev       \
                        linux-sound-base     \
                        libart-2.0-dev       \
                        libxtst-dev


# Dependencies for zoom
sudo apt-get install -y libxcb-image0  \
                        libxcb-keysyms1 \
                        libxcb-xtest0 \
                        libxslt1.1

# Get and install Zoom
cd /tmp
wget https://zoom.us/client/latest/zoom_i386.deb
dpkg -i zoom_i386.deb
rm zoom_i386.deb
cd -

# ... if any missed prereqs, this might fix it automatically
sudo apt-get -f install

# Copy files into home dir
echo "Running: rsync -a $source_dir/ $HOMEDIR/"
ls -aF "$source_dir"
rsync -a "$source_dir/" "$HOMEDIR/"
chown -R $USER:$USER $HOMEDIR

# Remove some unnecessary packages, clear apt caches and clean up
# (Although none of this actually reduces disk file size since we're not
# zeroing the data on the disk and reducing the image size accordingly)
apt-get remove -y lxmusic juju --auto-remove
apt-get autoremove
apt-get autoclean
apt-get clean
rm -rf /tmp/* /var/{cache,tmp}/* /var/lib/apt/lists/*

# Firefox plugin configuration
sudo update-alternatives --set mozilla-javaplugin.so /usr/lib/jvm/java-7-openjdk-i386/jre/lib/i386/IcedTeaPlugin.so

# The blacklist gets rid of all useless login names from LXDM login screen
# However, then autologin is added anyway, so the login screen is skipped.
# BUT autologin failed to work, maybe the whitelist is required for this.
# Since this configuration works I'll just leave it as-is, even the blacklist
# is kept for possible future use.
echo "[base]" >>$LXDE_CONF
echo "white=$USER" >>$LXDE_CONF
echo "black=syslog usbmux messagebus pollinate colord statd puppet" >> $LXDE_CONF
echo -e "[base]\nautologin=$USER" >> $LXDE_CONF

# Don't need these
userdel puppet || true
userdel ubuntu || true

# This weirdness now cause issues with apt-get.  Remove those puppet lines
sudo sed -i '/puppet/d' /var/lib/dpkg/statoverride


