{% import_yaml 'router/config.yml' as config %}

resolver-packages:
  pkg.latest:
    - pkgs:
      - unbound

root-hints-cron:
  file.managed:
    - name: /etc/cron.d/hints
    - contents:
      - 13 3 * * *  root  [ -d /etc/unbound ] && /usr/bin/wget -q "https://www.internic.net/domain/named.cache" -O /etc/unbound/root.hints

disable-dnssec:
  file.absent:
    - name: /etc/unbound/unbound.conf.d/root-auto-trust-anchor-file.conf
    - require:
      - pkg: resolver-packages

create-root-hints:
  cmd.run:
    - name: wget -q "https://www.internic.net/domain/named.cache" -O /etc/unbound/root.hints
    - unless: "[ -f /etc/unbound/root.hints ]"

unbound-config:
  file.managed:
    - name: /etc/unbound/unbound.conf.d/router.conf
    - contents: |
        server:
          interface: {{ salt.pillar.get('lan:ip') }}
          access-control: {{ salt.pillar.get('lan:network') }}/{{ salt.pillar.get('lan:cidr') }} allow
          num-threads: 5
          do-ip6: no
          root-hints: "/etc/unbound/root.hints"
          local-zone: "10.in-addr.arpa" nodefault

unbound-service:
  service.running:
    - name: unbound
    - enable: true
    - require: 
      - pkg: resolver-packages
      - cmd: create-root-hints
      - file: disable-dnssec
      - file: root-hints-cron
    - watch:
      - file: unbound-config
