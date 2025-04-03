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
        wan_interface: {{ salt.pillar.get('wan:interface') }}

cloudflare-dns-update:
  file.managed:
    - name: /usr/local/bin/update_dns_cloudflare
    - source: salt://router/files/usr/local/gin/update_dns_cloudflare
    - mode: 0750
    - template: jinja
    - defaults:
        cloudflare_api_token: {{ salt.pillar.get('secrets:cloudflare') }}

dns-update-cron:
  file.managed:
    - name: /etc/cron.d/dnsup
    - contents: |
        */5 * * * *    root    /usr/local/bin/update_dns.sh
        */5 * * * *    root    /usr/local/bin/update_dns_cloudflare

{%- else %}

disable-dyndns-cron:
  file.absent:
    - name: /etc/cron.d/dnsup

{%- endif %}
