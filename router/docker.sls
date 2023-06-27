{% set oscodename = salt.grains.get('oscodename') %}
{% set osarch = salt.grains.get('osarch') %}

docker-repo:
  pkgrepo.managed:
    - name: deb [signed-by=/etc/apt/keyrings/docker.gpg arch={{ osarch }}] https://download.docker.com/linux/debian {{ oscodename }} stable
    - dist: {{ oscodename }}
    - file: /etc/apt/sources.list.d/docker.list
    - aptkey: false
    - key_url: https://download.docker.com/linux/debian/gpg

docker-packages:
  pkg.latest:
    - pkgs:
      - docker-ce 
      - docker-ce-cli 
      - containerd.io 
    - refresh: true 

