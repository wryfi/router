# saltstack router configs

These are my personal saltstack router configurations, for running a
debian-based router that uses eap_proxy to bypass at&t fiber's shitbox
router.

## required pillars

```
# wan interface is wired directly to the ONT
# copy the MAC address from your at&t provided router as 'mac'
# copy the DUID from your router's dhcp requests (tcpdump/wireshark)
wan:
  interface: enp1s0
  vlan_interface: enp1s0.0
  mac: '88:77:66:55:44:33'
  duid: '00:02:00:00 ...'

# shitbox interface is wired to the at&t provided shitbox router
shitbox:
  interface: enp2s0

# your local/internal home network
lan:
  interface: enp4s0
  ip: 192.168.1.1
  network: 192.168.1.0
  netmask: 255.255.255.0
  cidr: 24

resolvconf:
  search:
    - yourdomain.com
  nameservers:
    - 192.168.1.1

# kea dhcp4 configuration
kea:
  Dhcp4:
    interfaces-config:
      interfaces:
        - enp4s0
    lease-database:
      type: memfile
    expired-leases-processing:
      reclaim-timer-wait-time: 10
      flush-reclaimed-timer-wait-time: 25
      hold-reclaimed-time: 3600
      max-reclaim-leases: 100
      max-reclaim-time: 250
      unwarned-reclaim-cycles: 5
    valid-lifetime: 4000
    option-data:
      - name: domain-name-servers
        data: '192.168.1.1'
      - name: routers
        data: '192.168.1.1'
    subnet4:
      - subnet: 192.168.1.0/24
        pools:
          - pool: '192.168.1.25 - 192.168.1.225'
        reservations:
          - hw-address: '00:22:33:44:55:66'
            ip-address: '192.168.1.5'
  Logging:
    loggers:
      - name: kea-dhcp4
        output_options:
          - output: /var/log/kea-dhcp4.log
        severity: INFO
        debuglevel: 0

# if you use a dynamic dns provider, edit these details and set enable: true
dyndns:
  user: foobar
  server: ns.yourdomain.com
  enable: false

# enable to use unbound_refuse to blocklist ad/malware domains in the resolver
unbound:
  refuse: false

# set your dyndns basic auth password here
secrets:
  dyndns: ************
```