include:
  - router.ssh
  - router.docker
  - router.resolver
  - router.dyndns
  - router.kea
  - router.shorewall
  - router.firewalld
  - router.eap
  - router.ntp

saltstack-repo:
  pkgrepo.managed:
    - name: deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://repo.saltproject.io/salt/py3/debian/12/amd64/latest bookworm main
    - key_url: https://repo.saltproject.io/salt/py3/debian/11/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg
    - aptkey: False
    - file: /etc/apt/sources.list.d/backports.list

router-packages:
  pkg.latest:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - cron
      - curl
      - dhcpcd
      - dnsutils
      - ethtool
      - gnupg
      - gnupg-agent
      - htop
      - iftop
      - lsof
      - python3-docker
      - salt-minion
      - software-properties-common
      - tcpdump
      - vim-nox
      - vlan
      - wget
    - require:
      - pkgrepo: saltstack-repo
    - refresh: true

salt-minion-service-dead:
  service.dead:
    - name: salt-minion
    - enable: False

salt-minion-config:
  file.managed:
    - name: /etc/salt/minion
    - contents: |
        file_client: local
        file_roots:
          base:
            - /srv/salt
        pillar_roots:
          base:
            - /srv/pillar

wan-interface:
  network.managed:
    - name: {{ salt.pillar.get('wan:interface') }}
    - enabled: True
    - type: eth
    - proto: dhcp

wan-vlan-interface:
  network.managed:
    - name: {{ salt.pillar.get('wan:vlan_interface') }}
    - enabled: False
    - type: vlan
    - proto: dhcp
    - vlan-raw-device: {{ salt.pillar.get('wan:interface') }}
    - require:
      - network: wan-interface

router-interface:
  network.managed:
    - name: {{ salt.pillar.get('shitbox:interface') }}
    - enabled: False
    - type: eth
    - proto: manual

lan-interface:
  network.managed:
    - name: {{ salt.pillar.get('lan:interface') }}
    - enabled: True
    - type: eth
    - proto: static
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

dhclient-removed:
  pkg.purged:
    - pkgs:
        - dhclient

duid-override:
  file.absent:
    - name: /var/lib/dhcpcd/duid

dhcpcd-config:
  file.managed:
    - name: /etc/dhcpcd.conf
    - source: salt://router/files/etc/dhcpcd.conf
    - template: jinja
    - defaults:
        interface: {{ salt.pillar.get('wan:interface') }}
