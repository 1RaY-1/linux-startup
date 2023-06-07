#!/bin/bash

# exit on any error
set -e

if ! [ `command -v wget` ]; then
    echo "Need 'wget' oackage to download files from github!"
    echo "Install it with your package manager"
    exit 1
fi

echo -ne "Check-Ip installer for Linux/Termux\n"
sleep 2s

case $(uname -m) in
    x86_64) ARCH="amd64" 
    echo "Downloading executable for: ${ARCH}"; sleep 1s
    wget -O check-ip https://github.com/1ray-1/check-ip/releases/latest/download/check-ip-${ARCH}
    ;;
    i386 | i686) ARCH="i386" 
    echo "Downloading executable for: ${ARCH}"; sleep 1s
    wget -O check-ip https://github.com/1ray-1/check-ip/releases/latest/download/check-ip-${ARCH}
    ;;
    arm64) ARCH="arm64" 
    echo "Downloading executable for: ${ARCH}"; sleep 1s
    wget -O check-ip https://github.com/1ray-1/check-ip/releases/latest/download/check-ip-${ARCH}
    ;;
    aarch64) ARCH="aarch64"
    echo "Downloading executable for: ${ARCH}"; sleep 1s
    wget -O check-ip https://github.com/1ray-1/check-ip/releases/latest/download/check-ip-${ARCH}
    ;;
    *)
    echo "Will compile it from source"; sleep 1s
    wget https://raw.githubusercontent.com/1ray-1/check-ip/main/check-ip.c
    {
    gcc check-ip.c -o check-ip  &&
    echo "Compiled successfully" &&
    sleep 2s
    } || {
    echo "Looks like C compiler is not installed or something went wrong!"
    exit 
    }
    ;;
esac

chmod +x check-ip

# for android
if [ -d /data/data/com.termux/files/usr/bin/ ]; then
    echo "Installing check-ip in /data/data/com.termux/files/usr/bin/";sleep 1s
    # in case
    if [ -f /data/data/com.termux/files/usr/bin/check-ip ]; then
        echo "Hey '/data/data/com.termux/files/usr/bin/check-ip' already exists, will replace it. Press ENTER to continue"
        read tmp
        rm /data/data/com.termux/files/usr/bin/check-ip
    fi
    mv check-ip /data/data/com.termux/files/usr/bin/

# for linux
elif [ -d /usr/bin/ ]; then
    echo "Installing check-ip in /usr/bin/";sleep 1s
    if [ -f /usr/bin/check-ip ]; then
        echo "Hey '/usr/bin/check-ip' already exists, will replace it. Press ENTER to continue"
        read tmp
        sudo rm /usr/bin/check-ip
    fi
    sudo mv check-ip /bin/
    
elif [ -d /bin/ ]; then
    echo "Installing check-ip in /bin/";sleep 1s
    if [ -f /bin/check-ip ]; then
        echo "Hey '/bin/check-ip' already exists, will replace it. Press ENTER to continue"
        read tmp
        sudo rm /bin/check-ip
    fi
    sudo mv check-ip /bin/

else echo "Sorry, I don't know what to do."; exit 1
fi

echo -ne "Done!\nType 'check-ip -h' to get started."
echo "Or read README.md for more."
