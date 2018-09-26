kill-systemd-timesyncd:
  service.dead:
    - name: systemd-timesyncd
    - enable: false

openntpd-package:
  pkg.latest:
    - name: openntpd

openntpd-service:
  service.running:
    - name: openntpd
    - enable: true
    - require:
      - service: kill-systemd-timesyncd
