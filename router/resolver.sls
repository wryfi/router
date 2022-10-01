remove-unbound:
  pkg.removed:
    - name: unbound
    - require:
      - service: unbound-disable

unbound-disable:
  service.dead:
    - name: unbound
    - enable: false

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
      - ServerIP: 10.9.8.1
    - port_bindings:
      - 10.9.8.1:53:53/tcp
      - 10.9.8.1:53:53/udp
      - 10.9.8.1:80:80/tcp
      - 10.9.8.1:443:443/tcp
    - restart_policy: always
    - cap_add:
      - NET_ADMIN

