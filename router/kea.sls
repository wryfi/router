kea-packages:
  pkg.latest:
    - pkgs:
      - kea-admin
      - kea-dhcp4-server

kea-config:
  file.managed:
    - name: /etc/kea/kea-dhcp4.conf
    - source: salt://router/files/etc/kea/kea-dhcp4.conf

