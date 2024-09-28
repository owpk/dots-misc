#!/bin/bash

TARGET_DEPS=$1
DISTR=$(curl -Ls https://raw.githubusercontent.com/owpk/dots-misc/refs/heads/main/get-distro.sh | bash)

echo "Deps dir: $TARGET_DEPS"

function installArchlinuxDeps() {

   # Install yay
   if ! command -v yay > /dev/null
   then
   	sudo pacman -Sy --needed git base-devel
   	git clone https://aur.archlinux.org/yay.git
   	cd yay
   	makepkg -si
   
   	cd $DOT
   	sudo rm -rf yay
   fi
   
   # The script begins here.
   yay -S --noconfirm --needed "$(cat $1)"
}

if [[ "$DISTR" == 'arch'  ]]; then
   installArchlinuxDeps "$TARGET_DEPS"
else 
   echo "Your distro $DIST is not supported yet !!!"
   echo "Please make sure you have installed all needed dependecny manually"
   echo "Check '$TARGET_DEPS' dir for details"
   echo "You can install all needed dependencies manually and retry this script."

   read -p "Are you shure you want to continue? (Y/n)" Y

   case "$Y" in
      [yY]) ;;
      *) exit 0 ;;
   esac
fi
