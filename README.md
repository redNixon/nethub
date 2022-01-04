# WIP 🚧 Nethub 🚧 WIP

Nethub is a gateway service which combines VPN Privacy and P2P networking.
- User-friendly interface for service stats, changing VPN connection and N2N settings.
- Isolated NordVPN or ProtonVPN gateway for extra security and sharing a VPN connection to multiple devices on the network.
- Built-in N2N for private P2P networking, even behind a firewall.
- Easily deployable as a VM or IOT device.


## Architecture

- ❗ To allow IP whitelisting on the supernode, __Nethub's Edge service bypasses the NordVPN or ProtonVPN connection__ provided by Nethub's VPN service.
There's no setting to enable or disable this yet.
- 🚀 Any device connected to Nethub's LAN interface will be automatically connected through DHCP.



### Edge Service Diagram

_Click the [diagram](https://user-images.githubusercontent.com/96931710/148057918-a2ced68a-6388-4ddf-a9ba-61c9e3ef28e7.png) to enlarge it._
<img width="1659" alt="Edge Diagram" src="https://user-images.githubusercontent.com/96931710/148057918-a2ced68a-6388-4ddf-a9ba-61c9e3ef28e7.png">

_Nethub's edge service uses [Ntop's N2N](https://github.com/ntop/n2n) to provide connection to a public or self-hosted supernode. The supernode can create P2P connections with other Nethub instances or seperate N2N edges.
Settings for the edge can be configured through the Nethub VM's interface._



### VPN Service Diagram
_Click the [diagram](https://user-images.githubusercontent.com/96931710/148057926-35078922-ca2c-46d2-ab60-b147e18ef64c.png) to enlarge it._
<img width="1659" alt="VPN Diagram" src="https://user-images.githubusercontent.com/96931710/148057926-35078922-ca2c-46d2-ab60-b147e18ef64c.png">

_Nethub's VPN service uses [openvpn](https://github.com/OpenVPN/openvpn) to create a VPN connection to either [NordVPN](https://nordvpn.com) or [ProtonVPN](https://protonvpn.com). VPN settings such as country, protocol or credentials can be changed through Nethub's interface._
