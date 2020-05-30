#!/bin/bash
#
# GitHub:
# https://github.com/hwdsl2/docker-ipsec-vpn-server
#


ENV_FILE_EXAMPLE=vpn.env.example
ENV_FILE=vpn.env
NAME=ipsec-vpn-server


get_container_id() {
    docker ps --filter="name=$NAME" -q --no-trunc
}

is_container_created() {
    [[ $(docker ps -aq --format='{{.Names}}' | grep ipsec-vpn-server) ]]
}

check_env() {
    if [[ ! -f $ENV_FILE ]]; then
        echo 'error: please config first'
        exit 1
    fi
}


start() {
    if is_container_created; then
        echo "warning: container is already created"
        get_container_id
    else
        docker run --name $NAME \
            --env-file $ENV_FILE \
            --restart=always \
            -p 500:500/udp \
            -p 4500:4500/udp \
            -d --privileged \
            hwdsl2/ipsec-vpn-server
        (( ! $? )) \
            && echo "(created)" \
            || echo "error: failed to create container";

    fi
}

stop() {
    if is_container_created; then
        docker rm -f $NAME \
            && echo "(removed)"  \
            || echo "error: failed to remove container"
    else
        echo "warning: container doesn't exist"
    fi
}

config() {
    if [[ -f $ENV_FILE ]] \
            && ( read -p 'create new env file? [y/N] ' reply; [[ $reply =~ ^[Yy]$ ]] ) \
            || [[ ! -f $ENV_FILE ]]; then
        echo "(copying $ENV_FILE_EXAMPLE to $ENV_FILE)"
        cp $ENV_FILE_EXAMPLE $ENV_FILE || {
            echo '(failed)'
            exit 1
        }
    fi
    echo "(editing $ENV_FILE)"
    if [[ $EDITOR ]]; then
        $EDITOR $ENV_FILE
    else
        echo 'warning: cannot determine your editor'
        echo 'please edit' `realpath $1`
    fi
}

help() {
    echo "Usage: $0 <start|stop|config>"
}



case $1 in
    start)
        check_env
        start
        ;;
    stop)
        stop
        ;;
    config)
        config
        ;;
    *)
        help
        ;;
esac
