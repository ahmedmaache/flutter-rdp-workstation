#!/bin/sh
set -e
echo "🔧 Installing Xorg & Dummy Driver..."
sudo apk add xorg-server xf86-video-dummy xinit xauth

echo "🔓 Configuring Xwrapper..."
# Allow anybody to start X
if [ ! -f /etc/X11/Xwrapper.config ]; then
    sudo mkdir -p /etc/X11
    echo 'allowed_users=anybody' | sudo tee /etc/X11/Xwrapper.config
    echo 'needs_root_rights=yes' | sudo tee -a /etc/X11/Xwrapper.config
fi

echo "🖥️ Creating xorg.conf..."
sudo tee /etc/X11/xorg.conf << 'EOF'
Section "Device"
    Identifier "DummyDevice"
    Driver "dummy"
    VideoRam 256000
EndSection

Section "Monitor"
    Identifier "DummyMonitor"
    HorizSync   5.0 - 1000.0
    VertRefresh 5.0 - 200.0
    Option "Primary" "True"
EndSection

Section "Screen"
    Identifier "DummyScreen"
    Device "DummyDevice"
    Monitor "DummyMonitor"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Modes "1920x1080"
    EndSubSection
EndSection
EOF

echo "📝 Updating sesman.ini..."
# Ensure we use Xorg backend properly
sudo sed -i 's/^param=Xorg/param=\/usr\/bin\/Xorg/' /etc/xrdp/sesman.ini
# Point to our custom config if not already
if ! grep -q "/etc/X11/xorg.conf" /etc/xrdp/sesman.ini; then
    sudo sed -i 's/param=xrdp\/xorg.conf/param=\/etc\/X11\/xorg.conf/' /etc/xrdp/sesman.ini
fi

echo "🔄 Restarting XRDP..."
sudo pkill -9 xrdp || true
sudo pkill -9 xrdp-sesman || true
sudo /usr/sbin/xrdp
sudo /usr/sbin/xrdp-sesman

echo "✅ DONE!"
