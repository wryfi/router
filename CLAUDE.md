 # CLAUDE.md
 
 This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
 
 ## Project Overview
 
 This is a SaltStack configuration for a Debian-based home router. The configuration manages network interfaces, 
 firewall rules, DHCP, DNS resolution, and related services.
 
 ## Applying Configuration
 
 Run salt locally on the router (salt-minion is configured for local operation):
 ```bash
 salt-call --local state.apply
 ```
 
 To apply a specific state:
 ```bash
 salt-call --local state.apply router.firewalld
 ```
 
 ## Architecture
 
 ### State Files (*.sls)
 - `top.sls` - Entry point that applies the `router` state to all minions
 - `router/init.sls` - Main state that includes all sub-states and configures base packages, network interfaces, and sysctl settings
 - `router/firewalld.sls` - Firewall configuration using firewalld (active)
 - `router/shorewall.sls` - Legacy shorewall config (disabled, being removed)
 - `router/eap.sls` - EAP proxy for AT&T fiber authentication bypass
 - `router/kea.sls` - Kea DHCP4 server configuration
 - `router/resolver.sls` - DNS resolution via unbound + pihole (Docker container)
 - `router/dyndns.sls` - Dynamic DNS update scripts
 - `router/docker.sls` - Docker CE installation
 - `router/ssh.sls`, `router/ntp.sls`, `router/ubiquiti.sls` - Auxiliary services
 
 ### Configuration Templates
 Templates in `router/files/` use Jinja2 templating with pillar data. Key templates:
 - `etc/dhcpcd.conf` - DHCP client config for WAN interface
 - `etc/eap_proxy.conf` - EAP proxy interface mapping
 - `etc/unbound/unbound.conf.d/local-resolver.conf` - Unbound DNS config
 
 ### Required Pillar Data
 All network configuration is driven by pillar data (see README.md for full schema):
 - `wan:interface`, `wan:vlan_interface`, `wan:mac`, `wan:duid` - WAN/ONT connection
 - `shitbox:interface` - AT&T router passthrough interface
 - `lan:interface`, `lan:ip`, `lan:network`, `lan:netmask`, `lan:cidr` - LAN network
 - `untrusted_iot:interface`, `untrusted_iot:ip`, `untrusted_iot:netmask` - IoT VLAN
 - `kea:Dhcp4` - Full Kea DHCP4 configuration object
 - `secrets:dyndns`, `secrets:cloudflare` - API credentials
 
 ## Key Design Patterns
 
 - Network interfaces are managed declaratively via `network.managed` states
 - Services watch their config files and restart on changes
 - Firewalld zones map to network segments (external/WAN, internal/LAN, untrusted-iot)
 - Pihole runs as a Docker container, unbound provides upstream recursive DNS
 - EAP proxy bridges authentication between ONT and AT&T router
