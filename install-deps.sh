#!/bin/bash

TARGET_DEPS=$1
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

DISTR="$("$SCRIPT_DIR/get-distro.sh")"
echo "Detected distro: $DISTR"

installArchlinuxDeps() {
    if ! command -v yay > /dev/null; then
        sudo pacman -Sy --needed git base-devel

        local BUILD_DIR
        BUILD_DIR=$(mktemp -d)

        git clone https://aur.archlinux.org/yay.git "$BUILD_DIR/yay" || {
            echo "Error: failed to clone yay repository"
            rm -rf "$BUILD_DIR"
            exit 1
        }
        (cd "$BUILD_DIR/yay" && makepkg -si) || {
            echo "Error: failed to build yay"
            rm -rf "$BUILD_DIR"
            exit 1
        }
        rm -rf "$BUILD_DIR"
    fi

    yay -S --noconfirm --needed $(cat "$TARGET_DEPS/arch")
}

installDebianDeps() {
    sudo apt-get update
    sudo apt-get install -y $(cat "$TARGET_DEPS/debian")
}

installFedoraDeps() {
    sudo dnf install -y $(cat "$TARGET_DEPS/fedora")
}

installMacosDeps() {
    if ! command -v brew > /dev/null; then
        echo "Homebrew not found, installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            echo "Error: failed to install Homebrew"
            exit 1
        }
    fi

    brew install $(cat "$TARGET_DEPS/macos")
}

echo "Attempt to install dependencies for: $DISTR"

case "$DISTR" in
    macos)
        installMacosDeps
        ;;
    arch)
        installArchlinuxDeps
        ;;
    debian|ubuntu|linuxmint|pop)
        installDebianDeps
        ;;
    fedora|rhel|centos)
        installFedoraDeps
        ;;
    *)
        echo "Your distro '$DISTR' is not supported yet!"
        echo "Please make sure you have installed all needed dependencies manually."
        echo "Check '$TARGET_DEPS' dir for details."

        read -rp "Are you sure you want to continue? (Y/n) " Y
        case "$Y" in
            [yY]|"") ;;
            *) exit 0 ;;
        esac
        ;;
esac
