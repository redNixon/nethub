#!/bin/bash

# ------------------------------------SETTINGS---------------------------------
# Functions library to retrieve settings and change the nethub.conf file.
# -----------------------------------------------------------------------------

# Imports.
. libraries/exceptions.sh

# Write the nethub.conf file with current variables.
function write_settings {
    cat <<EOT > nethub.conf
vpn="${vpn}"
default_protocol="${default_protocol}"
secure_mode="${secure_mode}"
nord_server="${nord_server}"
nord_username="${nord_username}"
nord_password="${nord_password}"
proton_server="${proton_server}"
proton_username="${proton_username}"
proton_password="${proton_password}"
supernode_address="${supernode_address}"
supernode_port="${supernode_port}"
supernode_community="${supernode_community}"
supernode_fedkey="${supernode_fedkey}"
supernode_key="${supernode_key}"
supernode_username="${supernode_username}"
supernode_password="${supernode_password}"
EOT
}

function apply_vpn_settings {
    # Find server file path of specified server.
    if [[ -n "${server}" ]]; then
        path="$(find . -name "${server}")"
        code=$(echo "${path}" | grep "${1}" >&2 ; echo $?)
        if [[ ${code} = 1 ]]; then
            raise 8 "Server not valid for provider."
        fi
        declare "${1}_server"="${path}"
    fi

    # Convert username argument to corresponding VPN setting.
    if [[ -n "${username}" ]]; then
        declare "${1}_username"="${username}"
    fi

    # Convert password argument to corresponding VPN setting.
    if [[ -n "${password}" ]]; then
        declare "${1}_password"="${password}"
    fi

    # Write the changes to nethub.conf
    write_settings

    # Restart service if flag is set.
    if [[ -n "${restart}" ]]; then
        restart_vpn_service "${1}"
    fi
}

function apply_edge_settings {
    # Set supernode server address.
    if [[ -n "${server}" ]]; then
        supernode_address="${server}"
    fi

    # Set supernode server port.
    if [[ -n "${port}" ]]; then
        supernode_port="${port}"
    fi

    # Set edge community name.
    if [[ -n "${community}" ]]; then
        supernode_community="${community}"
    fi

    # Set supernode federation public key.
    if [[ -n "${fedkey}" ]]; then
        supernode_fedkey="${fedkey}"
    fi

    # Set edge encryption key.
    if [[ -n "${key}" ]]; then
        supernode_key="${key}"
    fi

    # Set edge username.
    if [[ -n "${username}" ]]; then
        supernode_username="${username}"
    fi

    # Set edge password.
    if [[ -n "${password}" ]]; then
        supernode_password="${password}"
    fi

    # Write the changes to nethub.conf
    write_settings

    # Restart service if flag is set.
    if [[ -n "${restart}" ]]; then
        restart_edge_service
    fi
}

# Applies all the settings based on the state of the current variables.
# $1 : vpn : [proton|nord|edge]
function apply_settings {
    case "$1" in
        nord|proton)
        apply_vpn_settings "${1}";
        ;;
        edge)
        apply_edge_settings;
        ;;
    esac
}

# Sets the udp_toggle flag.
# Function only called from the cli.sh library.
function apply_default_protocol {
    if [[ "${default_protocol}" = "udp" ]]; then
        udp_toggle=true;
        tcp_toggle=false;
    fi
    if [[ "${default_protocol}" = "tcp" ]]; then
        tcp_toggle=true;
        udp_toggle=false;
    fi
}

# Return some settings in a logical format.
function get {
    declare -a options=("country vpn server edge")
    case "${1}" in
        country) get "server" |
        grep -oP "((?<=[^\w])([a-z]{2})((?![\w])|(?=\d)))" |
        sed 'N;s/\n/ -> /';
        ;;
        vpn)
        echo "${vpn}";
        ;;
        server)
        server="${vpn}_server"; echo "${!server}";
        ;;
        edge)
        ip addr show dev edge0 | grep -oP "(?<=inet )[\d\.]+";
        ;;
        *)  # Unknown option.
        raise 3 "No such information to retrieve.\
\nChoose from: $(cyan "${options[*]}")"
        ;;
    esac
}
