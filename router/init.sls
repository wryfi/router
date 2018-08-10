include:
  - resolver
  - router.kea
  - router.shorewall

router-packages:
  pkg.latest:
    - pkgs:
      - dnsutils
      - gnupg
      - htop
      - iftop
      - lsof
      - tcpdump
      - vim-tiny

wan-interface:
  network.managed:
    - name: enp1s0
    - enabled: True
    - type: eth
    - proto: dhcp

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
