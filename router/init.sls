include:
  - router.docker
  - router.resolver
  - router.dyndns
  - router.kea
  - router.shorewall
  - router.eap
  - router.ntp

backports-repo:
  pkgrepo.managed:
    - name: deb http://deb.debian.org/debian buster-backports main
    - file: /etc/apt/sources.list.d/backports.list

router-packages:
  pkg.latest:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - curl
      - dnsutils
      - ethtool
      - gnupg
      - gnupg-agent
      - htop
      - iftop
      - lsof
      - python3-docker
      - software-properties-common
      - tcpdump
      - vim-nox
      - vlan
    - require:
      - pkgrepo: backports-repo
    - refresh: true
    

wan-interface:
  network.managed:
    - name: {{ salt.pillar.get('wan:interface') }}
    - enabled: True
    - type: eth
    - proto: manual
    - hwaddress: {{ salt.pillar.get('wan:mac') }}

wan-vlan-interface:
  network.managed:
    - name: {{ salt.pillar.get('wan:vlan_interface') }}
    - enabled: true
    - type: vlan
    - proto: dhcp
    - vlan-raw-device: {{ salt.pillar.get('wan:interface') }}
    - require:
      - network: wan-interface

router-interface:
  network.managed:
    - name: {{ salt.pillar.get('shitbox:interface') }}
    - enabled: True
    - type: eth
    - proto: manual

lan-interface:
  network.managed:
    - name: {{ salt.pillar.get('lan:interface') }}
    - enabled: True
    - type: eth
    - proto: none
    - ipaddr: {{ salt.pillar.get('lan:ip') }}
    - netmask: {{ salt.pillar.get('lan:netmask') }}

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
    - source: salt://router/files/etc/resolv.conf
    - template: jinja
    - defaults:
        search: {{ salt.pillar.get('resolvconf:search') }}
        nameservers: {{ salt.pillar.get('resolvconf:nameservers') }}

dhclient-config:
  file.managed:
    - name: /etc/dhcp/dhclient.conf
    - source: salt://router/files/etc/dhcp/dhclient.conf
