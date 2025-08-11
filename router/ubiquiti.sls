{% set unifi_gid = 999 %}
{% set controller_version = "7.4.162" %}

unifi_data_dir:
  file.directory:
    - name: /opt/unifi
    - user: {{ unifi_gid }}
    - group: {{ unifi_gid }}
    - mode: 755
    - makedirs: True

# Pull UniFi Docker image
unifi_docker_image:
  docker_image.present:
    - name: jacobalberty/unifi:{{ controller_version }}

# Create and run UniFi container
unifi_container:
  docker_container.running:
    - name: unifi-controller
    - image: jacobalberty/unifi:{{ controller_version }}
    - restart_policy: unless-stopped
    - port_bindings:
        "8080/tcp":
          - HostIp: "{{ salt.pillar.get("lan:ip") }}"
            HostPort: "8080"
        "8443/tcp":
          - HostIp: "{{ salt.pillar.get("lan:ip") }}"
            HostPort: "8443"
        "3478/udp":
          - HostPort: "3478"
        "10001/udp":
          - HostPort: "10001"
        "1900/udp":
          - HostPort: "1{{ unifi_gid }}"
    - environment:
      - TZ=America/Los_Angeles
      - JVM_MAX_HEAP_SIZE=1024M
      - JVM_INIT_HEAP_SIZE=256M
    - binds:
      - /opt/unifi:/unifi:rw
    - user: "{{ unifi_gid }}:{{ unifi_gid }}"
    - require:
      - docker_image: unifi_docker_image
      - file: unifi_data_dir
