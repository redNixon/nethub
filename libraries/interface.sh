#!/bin/bash

# ------------------------------------INTERFACE--------------------------------------
# Interface library for Nethub.
# -----------------------------------------------------------------------------

function choose_country_dialog {
    # Get a country abbriviation like us, be or ch.
    country_filter=$(dialog --stdout --no-cancel --inputbox "Country Abbriviation" 0 0)
    # Restart the VPN service which will use the new country_filter variable.
    restart_vpn_service "${vpn}"
    # Show an estimate timeout for connecting to the new server.
    dialog --sleep 4 --infobox "Connecting to server..." 0 0
}

function choose_vpn_dialog {
    # Save current vpn if action is i.e. aborted by user.
    tmp_vpn="${vpn}"

    # Choose between nord or proton.
    option=$(dialog --no-cancel --ok-label "Submit" --stdout --menu "options" 0 0 0\
    1 "NordVPN"\
    2 "ProtonVPN")
    case $option in
        1) vpn="nord" ;;
        2) vpn="proton" ;;
    esac
}

function connect_dialog {
    # Make sure secure by default is used, but only by this CLI.
    ${secure_toggle} && secure_toggle=true
    # Set TCP or UDP toggle based on default procol.
    [[ "${default_protocol}" = "tcp" ]] && tcp_toggle=true && udp_toggle=false
    [[ "${default_protocol}" = "udp" ]] && tcp_toggle=false && udp_toggle=true
    # If to toggle has been set apply a default.
    [[ -z "${default_protocol}" ]] && tcp_toggle=false && udp_toggle=true
    # Get server through country choice and restore VPN variable.
    choose_vpn_dialog; argument="${vpn}"
    choose_country_dialog; vpn="${tmp_vpn}"
}

function connection_dialog {
    # Show message box while waiting for connection status.
    dialog --infobox "Fetching connection information. This may ~4 seconds." 0 0
    # Show connection status (IP and Ping).
    dialog --colors --msgbox "$(connection_status)" 0 0
}

function nord_credentials_dialog {
    # Ask for and write NordVPN OpenVPN credentials.
    values=($(dialog --stdout --form\
    "Nethub network" 0 0 0 \
	"OpenVPN username"  1 1	"" 1 20 30 0 \
	"OpenVPN password:" 2 1	"" 2 20 30 0))
    [[ -n "${values[0]}" ]] && nord_username="${values[0]}"
    [[ -n "${values[0]}" ]] && nord_password="${values[1]}"
    write_settings
}

function proton_credentials_dialog {
    # Ask for and write ProtonVPN OpenVPN credentials.
    values=($(dialog --stdout --form\
    "Nethub network" 0 0 0 \
	"OpenVPN username"  1 1	"" 1 20 30 0 \
	"OpenVPN password:" 2 1	"" 2 20 30 0))
    [[ -n "${values[0]}" ]] && proton_username="${values[0]}"
    [[ -n "${values[1]}" ]] && proton_password="${values[1]}"
    write_settings
}

function protocol_dialog {
    selection=$(dialog --stdout --ok-label "Select"\
    --backtitle "Nethub ${NETHUB_VERSION}"\
    --menu "Default VPN Protocol" 0 0 0\
    1 "UDP"\
    2 "TCP")

    case $selection in
        1) default_protocol="udp" ;;
        2) default_protocol="tcp" ;;
    esac

    write_settings
    apply_default_protocol
}

function security_dialog {
    selection=$(dialog --stdout --ok-label "Select"\
    --backtitle "Nethub ${NETHUB_VERSION}"\
    --menu "Change Secure Core" 0 0 0\
    1 "Enable"\
    2 "Disable")

    case $selection in
        1) secure_toggle=true ;;
        2) secure_toggle=false ;;
    esac

    write_settings
}

function supernode_dialog {

    values=($(dialog --stdout --form\
    "Supernode settings" 0 0 0 \
	"Address"           1 1	"${supernode_address}" 1 20 30 0 \
	"Port:"             2 1	"${supernode_port}" 2 20 30 0\
    "Community"         3 1 "${supernode_community}" 3 20 30 0\
    "Federation"        4 1 "${supernode_fedkey}" 4 20 30 0\
    "Encryption Key"    5 1 "${supernode_key}" 5 20 30 0\
    "Username"          6 1 "${supernode_username}" 6 20 30 0\
    "Password"          7 1 "${supernode_password}" 7 20 30 0))

    [[ -n "${values[0]}" ]] && supernode_address="${values[0]}"
    [[ -n "${values[1]}" ]] && supernode_port="${values[1]}"
    [[ -n "${values[2]}" ]] && supernode_community="${values[2]}"
    [[ -n "${values[3]}" ]] && supernode_fedkey="${values[3]}"
    [[ -n "${values[4]}" ]] && supernode_key="${values[4]}"
    [[ -n "${values[5]}" ]] && supernode_username="${values[5]}"
    [[ -n "${values[6]}" ]] && supernode_password="${values[6]}"

    write_settings
}

function settings_dialog {
    selection=$(dialog --stdout --colors --ok-label "Select"\
    --backtitle "Nethub ${NETHUB_VERSION}"\
    --menu "Menu Options" 0 0 0\
    1 "Default protocol"\
    2 "Secure Core"\
    3 "NordVPN credentials"\
    4 "ProtonVPN credentials"\
    5 "Supernode settings")

    case $selection in
        1) protocol_dialog ;;
        2) security_dialog ;;
        3) nord_credentials_dialog ;;
        4) proton_credentials_dialog ;;
        5) supernode_dialog ;;
    esac
}

function menu_dialog {
    selection=$(dialog --stdout --colors --ok-label "Select"\
    --backtitle "Nethub ${NETHUB_VERSION}"\
    --menu "Menu Options" 0 0 0\
    1 "Show connection"\
    2 "Connect VPN"\
    3 "Re-Connect VPN"\
    4 "Disconnect VPN"\
    5 "Connect EDGE"\
    6 "Leave EDGE"\
    7 "Settings")

    case $selection in
        1) connection_dialog ;;
        2) connect_dialog ;;
        3) sudo systemctl restart nethub_vpn.service ;;
        4) stop_vpn_service ;;
        5) sudo systemctl restart nethub_edge.service ;;
        6) sudo systemctl stop nethub_edge.service ;;
        7) settings_dialog ;;
    esac

    status_dialog

}

function status_dialog {

    # Refresh the configuration variables.
    . nethub.conf

    empty_string="\Z1empty\Zn"
    provided_string="\Z2provided\Zn"
    # Check NordVPN credentials.
    nordvpn_status=$empty_string
    if $(check_credentials "nord"); then
        nordvpn_status=$provided_string
    fi
    # Check ProtonVPN credentials.
    protonvpn_status=$empty_string
    if $(check_credentials "proton"); then
        protonvpn_status=$provided_string
    fi

    
    current_provider="$(get vpn)"
    current_country="$(get country)"
    current_server="$(get server | grep -oP \\d+)"
    current_protocol="$(get server | grep -oP "(udp|tcp)(?=.ovpn)")"


    message="
    $(blue SERVICES)
    VPN: $(nethub_vpn_status)
    Edge: $(nethub_edge_status)

    $(blue CONNECTION)
    Edge: $(edge_address)

    $(blue CREDENTIALS)
    ProtonVPN: ${protonvpn_status}
    NordVPN: ${nordvpn_status}
    
    $(blue SETTINGS)
    Provider: ${current_provider}
    Country: ${current_country}
    Server: ${current_server}
    Protocol: ${current_protocol}
    "

    dialog --colors --ok-label "MENU"\
    --backtitle "Nethub ${NETHUB_VERSION}"\
    --title "Status Interface"\
    --msgbox "${message}" 0 0

    menu_dialog
}

function start_interface {
    # Alters output of functions in libraries and the main nethub script.
    interface_mode=true
    if secure_mode; then secure_toggle=true; fi
    status_dialog
}