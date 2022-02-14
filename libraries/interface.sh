#!/bin/bash

# ------------------------------------INTERFACE--------------------------------------
# Interface library for Nethub.
# -----------------------------------------------------------------------------

# TODO: I know this is very ugly!
# I'll short the data later for a better function.
function choose_country_dialog {

    # $1 : str : continent
    function continent_to_countries {
        grep -P "\| $1$" resources/countries | cut -d '|' -f 5
    }

    # $1 : str : country
    function country_to_2code {
        regex="(?<=\| )[A-Z]{2}(?= \|)" # | DE |
        grep -P "$1" resources/countries | grep -oP "$regex"
    }

    # Shows menu dialog for choosing a continent.
    function select_continent {
        # Show continents.
        option=$(dialog --no-cancel --ok-label "Submit" --stdout --menu "Continents" 0 0 0\
            1 "Africa"\
            2 "Antarctica"\
            3 "Asia"\
            4 "Europe"\
            5 "North America"\
            6 "Oceania"\
            7 "South America")

        # Translate user choice to continent.
        case $option in
            1) continent="Africa" ;;
            2) continent="Antarctica" ;;
            3) continent="Asia" ;;
            4) continent="Europe" ;;
            5) continent="North America" ;;
            6) continent="Oceania" ;;
            7) continent="South America" ;;
        esac
    }

    # Creates and shows menu dialog for choosing country in given continent.
    function select_country {
        
        # Create variables for dynamic menu creation.
        declare -a array; i=1; j=1

        # Dynamically create the countries menu.
        while read line; do 
            array[ $i ]=$j
            (( j++ ))
            array[ ($i + 1) ]=$line
            (( i=($i+2) ))
        done < <(continent_to_countries "$continent")

        # Show the countries and let the user select one.
        option=$(dialog --no-cancel --ok-label "Submit" --stdout --menu\
            "Countries" 0 0 0 "${array[@]}")

        # Translate user choice to country.
        country=$( echo "${array[@]}" |
            grep -oP "(?<=(?<!\d)$option )[^\d]+(?= )")
    }

    # Show continent selection dialog.
    select_continent
    # Show country selection dialog.
    select_country
    # Set the country filter as country code and translate it lowercase.
    country_filter=$(country_to_2code "${country}" | tr '[:upper:]' '[:lower:]')
    
    # Wait for the VPN to connect, or not to.
    wait_vpn_connect



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
        1) secure_toggle=true; secure_mode=true ;;
        2) secure_toggle=false; secure_mode=false ;;
    esac

    write_settings
}

function supernode_dialog {

    values=($(dialog --stdout --form\
    "Supernode settings" 0 0 0 \
	"Address"           1 1	"${supernode_address}" 1 20 50 0 \
	"Port:"             2 1	"${supernode_port}" 2 20 50 0\
    "Community"         3 1 "${supernode_community}" 3 20 50 0\
    "Federation"        4 1 "${supernode_fedkey}" 4 20 50 0\
    "Encryption Key"    5 1 "${supernode_key}" 5 20 50 0\
    "Username"          6 1 "${supernode_username}" 6 20 50 0\
    "Password"          7 1 "${supernode_password}" 7 20 50 0))

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

function wait_vpn_connect {

    function google_ping {
        ping -c 8.8.8.8 2>&1 >/dev/null
        echo $?
    }

    # Restart the nethub_vpn.service.
    restart_result=$(restart_vpn_service "${vpn}")

    if $restart_result = true; then
        # Wait for being able to ping to Google.
        i=10
        while [ $() -ne 0 ] && [ $i -ge 0 ]; do
            dialog --infobox "Connecting to VPN. Taking $i seconds." 0 0
            sleep 1
            let "i-=1"
            google_ping
        done

        # If 10 seconds passed show a time-out message.
        if [ $i -le 0 ]; then
            message="\Z1Timed out...\Zn"
            dialog --colors --backtitle "Failure"\
            --msgbox "${message}" 0 0
        fi
    else
        # Show message that no server could be found.
        if $secure_mode = true; then
            message=$(red "Could not find a secure server for $country, $country_filter.")
        else
            message=$(red "Could not find a server for $country,$country_filter.")
        fi
        dialog --colors --sleep 4 --infobox "${message}" 0 0
    fi


}

# Shows a waiting screen waiting for the vpn to connect.
function wait_vpn_restart {

    function google_ping {
        ping -c 8.8.8.8 2>&1 >/dev/null
        echo $?
    }

    # Restart the nethub_vpn.service.
    sudo systemctl restart nethub_vpn.service

    # Wait for being able to ping to Google.
    i=10
    while [ $() -ne 0 ] && [ $i -ge 0 ]; do
        dialog --infobox "Connecting to VPN. Taking $i seconds." 0 0
        sleep 1
        let "i-=1"
        google_ping
    done

    # If 10 seconds passed show a time-out message.
    if [ $i -le 0 ]; then
        message="\Z1Timed out...\Zn"
        dialog --colors --backtitle "Failure"\
        --msgbox "${message}" 0 0
    fi
}

# Shows a waiting screen waiting for the edge to connect.
function wait_edge {
    # Restart the nethub_edge.service.
    sudo systemctl restart nethub_edge.service

    # Wait for and edge address for up to 10 seconds.
    i=10
    while [ -z "$(edge_address)" ] && [ $i -ge 0 ]; do
        dialog --infobox "Connecting to edge. Taking $i seconds." 0 0
        sleep 1
        let "i-=1"
    done

    # If 10 seconds passed show a time-out message.
    if [ $i -le 0 ]; then
        message="\Z1Timed out...\Zn"
        dialog --colors --backtitle "Failure"\
        --msgbox "${message}" 0 0
    fi
}

function reload_status {
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

    # Get other static variables.
    current_provider="$(get vpn)"
    current_country="$(get country)"
    current_server="$(get server | grep -oP \\d+)"
    current_protocol="$(get server | grep -oP "(udp|tcp)(?=.ovpn)")"

    # Get dynamic statuses.
    current_vpn_status=$(nethub_vpn_status)
    current_edge_status=$(nethub_edge_status)
}

function menu_dialog {
    selection=$(dialog --stdout --colors --ok-label "Select"\
    --backtitle "Nethub ${NETHUB_VERSION}"\
    --menu "Menu Options" 0 0 0\
    1 "Refresh"\
    2 "Show connection"\
    3 "Connect VPN"\
    4 "Re-Connect VPN"\
    5 "Disconnect VPN"\
    6 "Connect EDGE"\
    7 "Leave EDGE"\
    8 "Settings")

    case $selection in
        1) reload_status ;;
        2) connection_dialog ;;
        3) connect_dialog ;;
        4) wait_vpn_restart ;;
        5) stop_vpn_service ;;
        6) wait_edge ;;
        7) sudo systemctl stop nethub_edge.service ;;
        8) settings_dialog ;;
    esac

    # Go back to status dialog.
    status_dialog

}

function status_dialog {
    # Load status variables.
    reload_status

    # Create message.
    message="
    $(blue SERVICES)
    VPN: ${current_vpn_status}
    Edge: ${current_edge_status}

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

    # Show message box with statuses.
    dialog --colors --ok-label "Menu"\
    --backtitle "Nethub ${NETHUB_VERSION}"\
    --title "Status Interface"\
    --msgbox "${message}" 0 0

    # Show menu dialog after message with statuses.
    menu_dialog
}

function start_interface {
    # Alters output of functions in libraries and the main nethub script.
    interface_mode=true
    if $secure_mode = true; then secure_toggle=true; else secure_toggle=false; fi
    status_dialog
}