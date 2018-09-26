include:
  - router.resolver
  - router.dyndns
  - router.kea
  - router.shorewall
  - router.eap
  - router.ntp

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
