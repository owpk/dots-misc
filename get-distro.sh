#!/bin/sh
# Detects the current OS and Linux distribution.
# Outputs a lowercase distro/OS identifier (e.g. arch, ubuntu, debian, fedora, macos).
# Uses /etc/os-release (modern standard) with fallback to legacy release files.

OS=$(uname -s)

if [ "${OS}" = "SunOS" ]; then
    OSSTR="solaris"
elif [ "${OS}" = "AIX" ]; then
    OSSTR="aix"
elif [ "${OS}" = "Darwin" ]; then
    OSSTR="macos"
elif [ "${OS}" = "Linux" ]; then
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        OSSTR="${ID}"
    elif [ -f /etc/redhat-release ]; then
        OSSTR="rhel"
    elif [ -f /etc/arch-release ]; then
        OSSTR="arch"
    elif [ -f /etc/debian_version ]; then
        OSSTR="debian"
    elif [ -f /etc/SuSE-release ]; then
        OSSTR="suse"
    else
        OSSTR="linux"
    fi
else
    OSSTR="${OS}"
fi

echo "${OSSTR}" | tr '[:upper:]' '[:lower:]'
