#!/bin/bash
#
# This script should be run at its location
#

IMAGE='dots-ikev2-vpn:1337'
NAME='dots-ikev2-vpn-server'
HOST_CONF=$PWD/config
CLIENT_CONF=${WORKDIR:-$PWD}/ikev2-vpn.mobileconfig

case $1 in
    build)
        docker build -t $IMAGE .
        ;;
    start)
        CONTAINER=`docker ps -aqf NAME=$NAME`
        if [ "no$CONTAINER" = no ]; then
            docker run \
                --name $NAME \
                --privileged \
                --detach \
                --rm \
                -v $HOST_CONF:/host_cfg \
                -p 500:500/udp \
                -p 4500:4500/udp \
                $IMAGE
        else
            echo "Already running as $CONTAINER"
        fi
        ;;
    stop)
        CONTAINER=`docker ps -aqf NAME=$NAME`
        [ ! "no$CONTAINER" = no ] && docker rm -f $CONTAINER
        ;;
    ps)
        docker ps -af NAME=ikev2-vpn-server
        ;;
    config)
        read -p 'Host: ' HOST
        read -p 'Connection Name: ' CONN_NAME
        read -p 'Profile Name: ' PROFILE_NAME
        docker run --privileged -it --rm --volumes-from $NAME \
            -e "HOST=$HOST" \
            -e "CONN_NAME=$CONN_NAME" \
            -e "PROFILE_NAME=$PROFILE_NAME" \
            $IMAGE dots-generate-mobileconfig > $CLIENT_CONF
        ;;
    *)
        echo "Usage: $0 <build|start|stop|ps|config>"
        ;;
esac
