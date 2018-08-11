dns-update-script:
  file.managed:
    - name: /usr/local/bin/update_dns.sh
    - source: salt://router/files/usr/local/bin/update_dns.sh
    - mode: 0750

dns-update-cron:
  file.managed:
    - name: /etc/cron.d/dnsup
    - contents: |
        */5 * * * *    root    /usr/local/bin/update_dns.sh
