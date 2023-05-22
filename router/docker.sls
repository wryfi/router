docker-repo:
  pkgrepo.managed:
    - name: deb [arch=amd64] https://download.docker.com/linux/debian bullseye stable
    - dist: bullseye
    - file: /etc/apt/sources.list.d/docker.list
    - keyid: 0EBFCD88
    - keyserver: keyserver.ubuntu.com

docker-packages:
  pkg.latest:
    - pkgs:
      - docker-ce 
      - docker-ce-cli 
      - containerd.io 
    - refresh: true 

