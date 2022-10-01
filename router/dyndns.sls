{%- if salt.pillar.get('dyndns:enable') %}

dns-update-script:
  file.managed:
    - name: /usr/local/bin/update_dns.sh
    - source: salt://router/files/usr/local/bin/update_dns.sh
    - template: jinja
    - mode: 0750
    - defaults:
        user: {{ salt.pillar.get('dyndns:user') }}
        password: {{ salt.pillar.get('secrets:dyndns') }}
        server: {{ salt.pillar.get('dyndns:server') }}
        hostname: {{ salt.grains.get('domain') }}   
        wan_interface: {{ salt.pillar.get('wan:vlan_interface') }}

dns-update-cron:
  file.managed:
    - name: /etc/cron.d/dnsup
    - contents: |
        */5 * * * *    root    /usr/local/bin/update_dns.sh

{%- else %}

disable-dyndns-cron:
  file.absent:
    - name: /etc/cron.d/dnsup

{%- endif %}
