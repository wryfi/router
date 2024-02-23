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
