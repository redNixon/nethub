#!/bin/bash

# ---------------------------------Colors--------------------------------------
# String formatting library for nethub.
# -----------------------------------------------------------------------------

# $1 : str : string to format.
function hr {
    echo -e "\n---------${1}---------\n"
}

# $1 : str : string to color.
function green {
    string="\e[32m$1\e[0m"
    if [[ $interface_mode = true ]]; then
        string="\Z2$1\Zn"
    fi
    echo -e "${string}"
}

# $1 : str : string to color.
function red {
    string="\e[31m$1\e[0m"
    if [[ $interface_mode = true ]]; then
        string="\Z1$1\Zn"
    fi
    echo -e "${string}"
}

# $1 : str : string to color.
function magenta {
    echo -e "\e[95m$1\e[0m"
}

# $1 : str : string to color.
function blue {
    string="\e[34m$1\e[0m"
    if [[ $interface_mode = true ]]; then
        string="\Z4$1\Zn"
    fi
    echo -e "${string}"
}

# $1 : str : string to color.
function dim {
    echo -e "\e[2m$1\e[0m"
}

# $1 : str : string to underline.
function underline {
    echo -e "\e[4m$1\e[0m"
}

# $1 : str : string to color.
function cyan {
    echo -e "\e[36m$1\e[0m"
}

# $1 : str : string to bolden.
function bold {
    echo -e "\e[1m$1\e[0m"
}
