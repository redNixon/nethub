#!/bin/bash

# ---------------------------------CHECKS--------------------------------------
# Checking functions library for nethub.
# -----------------------------------------------------------------------------

# Imports.
. libraries/colors.sh
. libraries/exceptions.sh

# Check if sudo permissions are available.
# Returns: error.
function check_permission {
    if [[ "${EUID}" -ne 0 ]]; then
        raise 6 "This options requires root permissions."
    fi
}

# Checks args on runs actions on -/-- cases.
# Returns: error.
function check_arg {
    # If option has no argument raise error.
    if [[ -z "${arg}" ]]; then
        raise 3 "${opt} requires an argument."
    fi
    # Required by assign_defaults to parse args without option prefix.
    pre_opt="${opt}"  # previous option
    pre_arg="${arg}"  # previous argument
}

# Raise exception and show available VPN providers
# if passed VPN provider is not in list.
# Returns: error.
function check_vpn {
    message=("${arg} is not a valid VPN provider."
            "\nPlease choose from: $(magenta "${providers[*]}")")
    case "${providers[@]}" in
        *"${arg}"*) : ;;
        *) raise 4 "${message[*]}" ;;
    esac
}

# Check if country abbreviation is correct.
# If no country has been provided or is incorrect display
# available options for selected VPN provider.
# Returns: error.
function check_country {
    # Get the possible options for nord or proton.
    if [[ "${argument}" = "nord" ]]; then options="${nord_abbr}"; fi
    if [[ "${argument}" = "proton" ]]; then options="${proton_abbr}"; fi
    # If the abbreviation isn't length 2 then it isn't correct.
    if [[ ${#arg} != 2 ]]; then
        raise 3 "Not a valid country abbreviation.\n\
For ${argument} Please choose from: $(cyan "${options}")"
    fi
}

# Check if credentials for specific VPN are provided.
# $1 : vpn : [proton|nord]
# Returns: exitcode
function check_credentials {
    username="${1}_username"; username="${!username}";
    password="${1}_password"; password="${!password}";
    if [[ -n "${username}" ]] && [[ -n "${password}" ]]; then
        echo true
    else
        echo false
    fi
}
