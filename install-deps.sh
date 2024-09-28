#:!/bin/bash

TARGET_DEPS=$1

# Detects which OS and if it is Linux then it will detect which Linux Distribution.
OS=`uname -s`
REV=`uname -r`
MACH=`uname -m`

GetVersionFromFile()
{
        VERSION=`cat $1 | tr "\n" ' ' | sed s/.*VERSION.*=\ // `
}

if [ "${OS}" = "SunOS" ] ; then
        OS=Solaris
        ARCH=`uname -p`
        OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
elif [ "${OS}" = "AIX" ] ; then
        OSSTR="${OS} `oslevel` (`oslevel -r`)"
elif [ "${OS}" = "Linux" ] ; then
        KERNEL=`uname -r`
        if [ -f /etc/redhat-release ] ; then
                DIST='RedHat'
                PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
                REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
        elif [ -f /etc/SuSE-release ] ; then
                DIST=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
                REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
        elif [ -f /etc/mandrake-release ] ; then
                DIST='Mandrake'
                PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
                REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
        elif [ -f /etc/debian_version ] ; then
                DIST="Debian `cat /etc/debian_version`"
                REV=""
        elif [ -f /etc/arch-release ] ; then
                DIST="Arch`cat /etc/arch-release`"
                REV=""

        fi
        if [ -f /etc/UnitedLinux-release ] ; then
                DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
        fi

        #OSSTR="${OS} ${DIST} ${REV}(${PSUEDONAME} ${KERNEL} ${MACH})"
        OSSTR="${DIST}"
fi

DISTR=$(echo $OSSTR | awk '{print tolower($0)}')
echo $DISTR

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
   yay -S --noconfirm --needed $(cat $TARGET_DEPS/$1)
}

if [[ "$DISTR" == 'arch'  ]]; then
   installArchlinuxDeps "$TARGET_DEPS/$DISTR"
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
