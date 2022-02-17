# Nethub

![release](https://img.shields.io/badge/Release-1.1.0-yellow)
![platform](https://img.shields.io/badge/Platform-Ubuntu%2020%20LTS-orange)
![vpns](https://img.shields.io/badge/Connections-NordVPN%20|%20ProtonVPN%20|%20N2N-blue)

Nethub is a gateway service which combines VPN Privacy and P2P networking.

- User-friendly interface for service stats, changing VPN connection and N2N settings.
- Isolated NordVPN or ProtonVPN gateway for extra security and sharing a VPN connection to multiple devices on the network.
- Built-in N2N for private P2P networking, even behind a firewall.
- Easily deployable as a VM or IOT device.

```
Nethub Virtual Architecture
---------------------------
VM1 |        | ProtonVPN
VM2 | Nethub | N2N Supernode
VM3 |        | NordVPN
```

```
Example Edge Architecture
-----------------------------------
Website |                | Nethub 1
Pi-hole | Edge/Supernode | Nethub 2
Shares  |                | Nethub 3
```

![GUI](https://user-images.githubusercontent.com/96931710/148556053-eeefb8c5-8f1b-44a5-8ec7-f7300ee4ab48.png)

## Architecture

- ❗ To allow IP whitelisting on the supernode, __Nethub's Edge service bypasses the NordVPN or ProtonVPN connection__ provided by Nethub's VPN service.
There's no setting to enable or disable this yet.
- 🚀 Any device connected to Nethub's LAN interface will be automatically connected through DHCP.

---

### Edge Service Diagram

_Click the [diagram](https://user-images.githubusercontent.com/96931710/148057918-a2ced68a-6388-4ddf-a9ba-61c9e3ef28e7.png) to enlarge it._
<img width="1659" alt="Edge Diagram" src="https://user-images.githubusercontent.com/96931710/148057918-a2ced68a-6388-4ddf-a9ba-61c9e3ef28e7.png">

_Nethub's edge service uses [Ntop's N2N](https://github.com/ntop/n2n) to provide connection to a public or self-hosted supernode. The supernode can create P2P connections with other Nethub instances or separate N2N edges.
Settings for the edge can be configured through the Nethub VM's interface._

---

### VPN Service Diagram

_Click the [diagram](https://user-images.githubusercontent.com/96931710/148057926-35078922-ca2c-46d2-ab60-b147e18ef64c.png) to enlarge it._
<img width="1659" alt="VPN Diagram" src="https://user-images.githubusercontent.com/96931710/148057926-35078922-ca2c-46d2-ab60-b147e18ef64c.png">

_Nethub's VPN service uses [openvpn](https://github.com/OpenVPN/openvpn) to create a VPN connection to either [NordVPN](https://nordvpn.com) or [ProtonVPN](https://protonvpn.com). VPN settings such as country, protocol or credentials can be changed through Nethub's interface._

---

## Installation

**Warning**: the installation of Nethub will make critical changes to
your device. Make sure you know what you are doing.

### Prerequisites

- Virtual [Ubuntu 20 LTS server](https://ubuntu.com/download/server).
    - [N2N 3.0.0-1038](https://github.com/ntop/n2n/releases)
    - Virtual WAN network adapter.
    - Virtual LAN network adapter.

### Steps

1. [Download](https://github.com/ntop/n2n/releases) N2N:
1. [Download](https://github.com/kevinderuijter/nethub/releases) Nethub.
1. Run `sudo dpkg -i n2n_<version>_amd64.deb`.
1. Run `sudo apt-get install ./nethub_<version>_amd64.deb`.
    1. Select `YES` when asked to save IPv4 and IPv6 tables.
    1. Enter the name of your `WAN interface`.
    1. Enter the name of your `LAN interface`.
1. Reboot: `sudo shutdown -r now`.

## Quickstart

For the complete manual use `man nethub` or `nethub --help`.

1. Download OVPN files.
    ```sh
    # Download NordVPN servers automatically.
    # ProtonVPN servers have to be downloaded manually as instructed from nethub download.
    nethub download
    ```
1. Set credentials.
    ```sh
    # Set credentials and server for ProtonVPN.
    nethub set proton --username ... --password ...
    # Set credentials and server for NordVPN.
    nethub set nord --username ... --password ...
    ```
1. Connect.
    ```sh
    # Connect to NordVPN
    nethub connect nord --country us
    # Re-connect to ProtonVPN
    nethub connect proton --country nl
    ```
1. Get ip and country.
    ```sh
    # Get the connection details
    nethub status connection
    ```
    ```sh
    # This is the result that will display.
    Fetching connection information. This may ~4 seconds.
    -----------------------------------------------------------
    PING 8.8.8.8 (8.8.8.8) from 10.8.2.10 tun0: 56(84) bytes of data.
    64 bytes from 8.8.8.8: icmp_seq=1 ttl=119 time=13.8 ms
    64 bytes from 8.8.8.8: icmp_seq=2 ttl=119 time=13.7 ms
    64 bytes from 8.8.8.8: icmp_seq=3 ttl=119 time=13.7 ms

    --- 8.8.8.8 ping statistics ---
    3 packets transmitted, 3 received, 0% packet loss, time 2004ms
    rtt min/avg/max/mdev = 13.677/13.740/13.820/0.059 ms
    -----------------------------------------------------------
    {
    "ip": "193.29.60.136",
    "city": "Amsterdam",
    "region": "North Holland",
    "country": "NL",
    "loc": "52.3630,4.8924",
    "org": "AS49981 WorldStream B.V.",
    "postal": "1017",
    "timezone": "Europe/Amsterdam",
    "readme": "https://ipinfo.io/missingauth"
    }
    -----------------------------------------------------------
    ```

## Tests

To run the tests please make sure you conform to the following prerequisites:
- Installed Nethub with the steps above.
- Have all the NordVPN and ProtonVPN servers downloaded.
- Have provided the NordVPN and ProtonVPN OVPN credentials.
- Know which tests to disable if you're not using all VPN providers or N2N.

To run the test invoke `./tests`

## Edges

In order to get new devices or servers into the N2N P2P network without installing or connecting to a Nethub VM follow these steps:
1. [Download and install N2N](#Steps).
1. Copy the configured `nethub.conf` file to the target server.
1. Copy the [nethub_edge](nethub_edge) script to the target server.
1. Copy the [libraries folder for the exceptions.sh](libraries/exceptions.sh).
1. Invoke `sudo ./nethub_edge` or create an edge.
