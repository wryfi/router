#!/bin/bash

set -e -u

readonly ip="$(ip -f inet addr show {{ wan_interface }} | grep -Po 'inet \K[\d.]+')"
curl "https://{{ user }}:{{ password }}@{{ server }}/nic/update?hostname={{ hostname }}&myip=${ip}"
exit $?
