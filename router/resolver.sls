{% set pihole_ip = salt.pillar.get('lan:ip') %}

unbound-packages:
  pkg.latest:
    - name: unbound
    - pkgs:
      - unbound
      - dns-root-data

unbound-config:
  file.managed:
    - name: /etc/unbound/unbound.conf.d/local-resolver.conf
    - source: salt://router/files/etc/unbound/unbound.conf.d/local-resolver.conf
    - template: jinja
    - defaults:
        pihole_ip: {{ pihole_ip }}
    - require:
      - pkg: unbound-packages

unbound-service:
  service.running:
    - name: unbound
    - enable: true
    - watch:
      - file: unbound-config

pihole-volume:
  file.directory:
    - name: /opt/pihole/etc/pihole
    - mode: 0755

dnsmasq-volume:
  file.directory:
    - name: /opt/pihole/etc/dnsmasq.d
    - mode: 0755

pihole-network:
  docker_network.present:
    - name: pihole-network

pihole-ftl-config:
  file.managed:
    - name: /opt/pihole/etc/pihole/pihole-FTL.conf
    - source: salt://router/files/etc/pihole/pihole-FTL.conf
    - template: jinja
    - defaults:
        pihole_ip: {{ pihole_ip }}
    - require:
      - file: pihole-volume

pihole-container:
  docker_container.running:
    - name: pihole
    - image: pihole/pihole:latest
    - dns: 8.8.8.8
    - binds:
      - /opt/pihole/etc/pihole:/etc/pihole
      - /opt/pihole/etc/dnsmasq.d:/etc/dnsmasq.d
    - environment:
      - TZ: America/Los_Angeles
      - ServerIP: {{ pihole_ip }}
      - PIHOLE_DNS_: {{ pihole_ip }}#5335
    - port_bindings:
      - {{ pihole_ip }}:53:53/tcp
      - {{ pihole_ip }}:53:53/udp
      - {{ pihole_ip }}:80:80/tcp
      - {{ pihole_ip }}:443:443/tcp
    - restart_policy: always
    - cap_add:
      - NET_ADMIN
    - watch:
      - file: pihole-ftl-config