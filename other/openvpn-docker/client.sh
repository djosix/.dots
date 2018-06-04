#!/bin/bash

CONFIG=.ovpn.config
if [ ! -f $CONFIG ]; then
    echo "Error: Not configured yet."
    exit
fi
source $CONFIG

DOCKER_PS=`docker run -v $VOLUME:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn`
docker run -v $VOLUME:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full $CLIENT nopass
docker run -v $VOLUME:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient "$CLIENT" > "$CLIENT.ovpn"
docker stop $DOCKER_PS
