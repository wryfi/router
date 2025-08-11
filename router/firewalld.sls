firewalld-packages:
  pkg.latest:
    - pkgs:
      - firewalld

service-ssh-high:
  firewalld.service:
    - name: ssh-high
    - ports:
        - 2222/tcp

zone-external:
  firewalld.present:
    - name: external
    - default: True
    - interfaces:
        - {{ salt.pillar.get('wan:interface') }}
    - masquerade: True
    - block_icmp:
        - echo-reply
        - echo-request
    - services:
        - dhcp
        - ssh-high
    - require:
        - firewalld: service-ssh-high

zone-internal:
  firewalld.present:
    - name: internal
    - default: False
    - interfaces:
        - {{ salt.pillar.get('lan:interface') }}
    - services:
        - dhcp
        - dns
        - dns-over-tls
        - http
        - http3
        - https
        - ssh-high

create_untrusted_zone:
  cmd.run:
    - name: firewall-cmd --permanent --new-zone=untrusted-iot
    - unless: firewall-cmd --get-zones | grep -q untrusted-iot

# Reload firewalld after creating zone
reload_firewalld_after_zone_creation:
  cmd.run:
    - name: firewall-cmd --reload
    - onchanges:
      - cmd: create_untrusted_zone

# Configure untrusted zone
configure_untrusted_zone:
  firewalld.present:
    - name: untrusted-iot
    - interfaces:
      - {{ salt.pillar.get("untrusted_iot:interface") }}
    - masquerade: True
    - rich_rules:
      - 'rule family="ipv4" destination address="192.168.20.1" port port="53" protocol="tcp" accept'
      - 'rule family="ipv4" destination address="192.168.20.1" port port="53" protocol="udp" accept'
      - 'rule family="ipv4" destination address="192.168.20.1" port port="67" protocol="udp" accept'
      - 'rule family="ipv4" destination address="10.0.0.0/8" reject'
      - 'rule family="ipv4" destination address="192.168.0.0/16" reject'
      - 'rule family="ipv4" destination address="172.16.0.0/12" reject'
    - require:
      - cmd: reload_firewalld_after_zone_creation