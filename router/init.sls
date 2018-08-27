include:
  - resolver
  - router.dyndns
  - router.kea
  - router.shorewall
  - router.eap

router-packages:
  pkg.latest:
    - pkgs:
      - curl
      - dnsutils
      - ethtool
      - gnupg
      - htop
      - iftop
      - lsof
      - tcpdump
      - vim-nox
      - vlan

wan-interface:
  network.managed:
    - name: enp1s0
    - enabled: True
    - type: eth
    - proto: manual
    - hwaddress: 2c:95:69:58:4e:c1

wan-vlan-interface:
  network.managed:
    - name: enp1s0.0
    - enabled: true
    - type: vlan
    - proto: dhcp
    - vlan-raw-device: enp1s0
    - require:
      - network: wan-interface

router-interface:
  network.managed:
    - name: enp2s0
    - enabled: True
    - type: eth
    - proto: manual

lan-interface:
  network.managed:
    - name: enp4s0
    - enabled: True
    - type: eth
    - proto: none
    - ipaddr: 10.9.8.1
    - netmask: 255.255.255.0

vm-swappiness:
  sysctl.present:
    - name: vm.swappiness
    - value: 1

ip-forward-enable:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1
    

resolvconf:
  file.managed:
    - name: /etc/resolv.conf
    - contents:
      - domain isla.xyz.wry.fi.
      - search isla.xyz.wry.fi.
      - nameserver 10.9.8.1
      - nameserver 8.8.8.8

dhclient-config:
  file.managed:
    - name: /etc/dhcp/dhclient.conf
    - source: salt://router/files/etc/dhcp/dhclient.conf
