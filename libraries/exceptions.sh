#!/bin/bash

# --------------------------------EXCEPTIONS-----------------------------------
# Exception handling library for nethub.
# -----------------------------------------------------------------------------

# Imports.
. libraries/colors.sh

# Raise a previously defined error.
# $1 : int : error code.
# $2 : str : error message.
function raise { echo -e "$(red "${errors[${1}]}"): ${2}" >&2 ; exit ${1} ; }

# Raise a previously defined error but wait for keypress instead of exiting.
# $1 : int : error code.
# $2 : str : error message.
function warn { echo -en "$(red "${errors[${1}]}"): ${2}" >&2 ; read ; }

# Custom error / exit codes.
declare -A errors
errors[3]="ArgumentError"       # Invalid arguments.
errors[4]="OptionError"         # Invalid options.
errors[5]="DependencyError"     # Missing dependency.
errors[6]="PermissionError"     # Missing required permissions.
errors[7]="ConnectionError"     # Connection failed
