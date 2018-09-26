{% import_yaml 'router/config.yml' as config %}

install-eap-deps:
  pkg.installed:
    - pkgs:
      - python2.7

install-eap-proxy:
  pkg.installed:
    - sources:
      - eap-proxy: salt://router/packages/eap-proxy_0.0.2_all.deb
    - require:
      - pkg: install-eap-deps

eap-proxy-config:
  file.managed:
    - name: /etc/eap_proxy.conf
    - source: salt://router/files/etc/eap_proxy.conf
    - template: jinja
    - defaults:
        IF_WAN: {{ salt.pillar.get('wan:interface') }}
        IF_ROUTER: {{ salt.pillar.get('shitbox:interface') }}

eap-proxy-service:
  service.running:
    - name: eap-proxy
    - enable: true
    - watch:
      - file: eap-proxy-config
