#!/bin/bash

IMAGE='kylemanna/openvpn:2.4'
NAME='dots-openvpn-server'
VOLUME="$PWD/volume"
DEFAULT_CLIENT="$USER@`hostname`"
: ${WORKDIR='.'}

case $1 in
    init) # initialize docker container
        DOMAIN=$2
        [[ $DOMAIN ]] || {
            echo 'Error: Expect a domain name as argument.' >&2
            exit
        }
        mkdir -p $VOLUME
        docker run -v $VOLUME:/etc/openvpn --rm $IMAGE ovpn_genconfig -u udp://$DOMAIN
        docker run -v $VOLUME:/etc/openvpn --rm -it $IMAGE ovpn_initpki
        ;;
    client) # generate client profile
        CLIENT=${2:-$DEFAULT_CLIENT}
        CONTAINER=`docker run -v $VOLUME:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN $IMAGE`
        docker run -v $VOLUME:/etc/openvpn --rm -it $IMAGE easyrsa build-client-full $CLIENT nopass
        docker run -v $VOLUME:/etc/openvpn --rm $IMAGE ovpn_getclient "$CLIENT" > "$WORKDIR/$CLIENT.ovpn"
        docker stop $CONTAINER
        ;;
    start) # start docker container
        docker run \
            --name $NAME \
            --cap-add=NET_ADMIN \
            --detach --restart unless-stopped \
            --volume $VOLUME:/etc/openvpn \
            --publish 1194:1194/udp \
            $IMAGE
        ;;
    stop) # stop docker container
        CONTAINER=`docker ps -aqf NAME=$NAME`
        [ "no$CONTAINER" = "no" ] || docker rm -f $CONTAINER
        ;;
    ps) # show running container
        docker ps -af NAME=$NAME
        ;;
    *)
        echo "Usage: $0 <init|client|start|stop|ps>"
esac
