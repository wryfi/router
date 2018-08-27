shorewall-packages:
  pkg.latest:
    - pkgs:
      - shorewall
      - shorewall-doc

shorewall-params:
  file.managed:
    - name: /etc/shorewall/params
    - contents: |
        WAN_IF=enp1s0.0
        LAN_IF=enp4s0
        INTERNAL=10.9.8.0/24

shorewall-zones:
  file.managed:
    - name: /etc/shorewall/zones
    - contents: |
        fw firewall
        wan ipv4
        lan ipv4

shorewall-interfaces:
  file.managed:
    - name: /etc/shorewall/interfaces
    - contents: |
        ?FORMAT 2
        wan  $WAN_IF  logmartians=1,routefilter=2,nosmurfs
        lan  $LAN_IF

shorewall-policy:
  file.managed:
    - name: /etc/shorewall/policy
    - contents: |
        $FW     wan    ACCEPT
        $FW     lan    ACCEPT
        lan     $FW    ACCEPT
        lan     wan    ACCEPT
        wan     all    DROP      info
        all     all    REJECT    info

shorewall-rules:
  file.managed:
    - name: /etc/shorewall/rules
    - contents: |
        ?SECTION ALL
        ?SECTION ESTABLISHED
        ?SECTION RELATED
        ?SECTION INVALID
        ?SECTION UNTRACKED
        ?SECTION NEW
        # Drop packets in the INVALID state
        Invalid(DROP)   wan             $FW             tcp

        # Drop Ping from the wan
        Ping(DROP)      wan             $FW

        # Permit outgoing ICMP
        ACCEPT          $FW             wan             icmp

        # Permit incoming ssh
        ACCEPT          wan             $FW             tcp     2222

shorewall-snat:
  file.managed:
    - name: /etc/shorewall/snat
    - contents: |
        MASQUERADE  $INTERNAL    $WAN_IF

enable-shorewall:
  cmd.run:
    - name: sed -i 's/startup=0/startup=1/g' /etc/default/shorewall
    - unless: grep startup=1 /etc/default/shorewall

shorewall-service:
  service.running:
    - name: shorewall
    - enable: true
    - watch:
      - file: shorewall-rules
      - file: shorewall-policy
      - file: shorewall-zones
      - file: shorewall-interfaces
      - file: shorewall-params
