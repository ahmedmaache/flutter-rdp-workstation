#!/bin/bash
set -e

echo "📦 Installing Dependencies..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y \
    curl git wget unzip xz-utils zip libglu1-mesa \
    openjdk-17-jdk \
    xfce4 xfce4-goodies dbus-x11 \
    xrdp \
    chromium-browser

echo "🐧 Configuring XRDP for XFCE..."
# Configure XRDP to use XFCE
echo "xfce4-session" > ~/.xsession
sudo sed -i 's/3389/3389/g' /etc/xrdp/xrdp.ini
sudo sed -i 's/max_bpp=32/max_bpp=128/g' /etc/xrdp/xrdp.ini
sudo sed -i 's/xserverbpp=24/xserverbpp=128/g' /etc/xrdp/xrdp.ini

# Enable the service
sudo service xrdp start

echo "📱 Installing Android Studio..."
# Define versions
ANDROID_STUDIO_URL="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.1.1.28/android-studio-2023.1.1.28-linux.tar.gz"
INSTALL_DIR="/usr/local/android-studio"

if [ ! -d "$INSTALL_DIR" ]; then
    sudo mkdir -p /usr/local/android-studio
    curl -L $ANDROID_STUDIO_URL -o /tmp/android-studio.tar.gz
    sudo tar -xzf /tmp/android-studio.tar.gz -C /usr/local/
    rm /tmp/android-studio.tar.gz
    echo "✅ Android Studio Installed to /usr/local/android-studio"
fi

# Add to PATH
echo 'export PATH=$PATH:/usr/local/android-studio/bin' >> ~/.bashrc
echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools' >> ~/.bashrc

echo "🧹 Cleaning up..."
sudo apt-get clean

echo "✅ Setup Complete! Connect via RDP to localhost:3390"
