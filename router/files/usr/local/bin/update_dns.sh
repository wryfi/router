#!/bin/bash

set -e -u

readonly ip="$(ip -f inet addr show enp1s0 | grep -Po 'inet \K[\d.]+')"
curl "https://wryfi:chievai5Ook1haij0ph@ns.wryfi.net/nic/update?hostname=isla.xyz.wry.fi&myip=${ip}"
exit $?
