#!/bin/bash

CONFIG=.ovpn.config
if [ ! -f $CONFIG ]; then
    echo "Error: Not configured yet."
    exit
fi
source $CONFIG

docker volume create --name $VOLUME
docker run -v $VOLUME:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://$DOMAIN
docker run -v $VOLUME:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
