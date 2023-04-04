#!/bin/bash

set -e

if [ $( uname -m ) == "x86_64" ] ; then 
   ARCH="x64" 
elif [ $( uname -m ) == "aarch64" ] ; then 
   ARCH="arm64" 
elif [ $( uname -m ) == "armv7l" ] ; then 
   ARCH="armhf" 
else 
   echo "Unsupported architecture: $( uname -m )" 
   exit 1 
 fi

LATEST_VERSION_URL=$( curl -w "%{url_effective}\n" -I -L -s -S "https://code.visualstudio.com/sha/download?build=stable&os=linux-$ARCH" -o /dev/null )
LATEST_VERSION=$( echo $( echo $LATEST_VERSION_URL | awk -F '/' '{print $6}') | sed -r 's/.*-([0-9]+)\.tar\.gz/\1/' )
CURRENT_VERSION=$( cat /opt/VSCode/version 2>/dev/null )  || CURRENT_VERSION="0"

unpack() {
   curl -o vscode.tar.gz -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-$ARCH"
   echo "Stopping VSCode, if it's running..."
   if pgrep code > /dev/null; then
     pkill -9 code
   fi
   if [ -d "/opt/VSCode" ]; then
     rm -rf /opt/VSCode-linux-$ARCH
   fi
   tar -xzf vscode.tar.gz -C /opt/
   printf "$LATEST_VERSION" > /opt/VSCode-linux-$ARCH/version
   ln -sf /opt/VSCode-linux-$ARCH/bin/code /usr/bin/code
   if [ ! -f "/usr/share/applications/code.desktop" ]; then
     echo "Creating desktop entry for VSCode..."
     printf '[Desktop Entry]\nName=VSCode\nComment=Visual Studio Code\nExec=/usr/bin/code\nIcon=/opt/VSCode/VSCode-linux-$ARCH/resources/app/resources/linux/code.png\nTerminal=false\nType=Application\nCategories=Development;\n' > /usr/share/applications/code.desktop
   fi
   echo "Cleaning up..."
   rm -f vscode.tar.gz
   echo "Starting VSCode ($LATEST_VERSION)"
   /usr/bin/code --no-sandbox & disown
   echo "Done."
}
unpack
