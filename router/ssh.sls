ssh-server-package:
  pkg.latest:
    - pkgs:
        - openssh-server

sshd-config:
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: salt://router/files/etc/ssh/sshd_config

ssh-service:
  service.running:
    - name: ssh
    - enable: true
    - watch:
        - file: sshd-config