kea-packages:
  pkg.latest:
    - pkgs:
      - kea-admin
      - kea-dhcp4-server

kea-dhcp4-config:
  file.managed:
    - name: /etc/kea/kea-dhcp4.conf
    - source: salt://router/files/etc/kea/kea-dhcp4.conf

kea-service:
  service.running:
    - name: kea-dhcp4-server
    - enable: true
    - watch:
      - file: kea-dhcp4-config

