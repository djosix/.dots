#!/bin/sh

CONFIG=".ovpn.config"

DEFAULT_VOLUME="ovpn-data"
DEFAULT_CLIENT="$USER@`hostname`"

read -p "Docker volume [$DEFAULT_VOLUME]: " VOLUME
read -p "Client name [$DEFAULT_CLIENT]:" CLIENT
read -p "Your domain name: " DOMAIN

VOLUME=${VOLUME:-$DEFAULT_VOLUME}
CLIENT=${CLIENT:-$DEFAULT_CLIENT}
if [ ! "$DOMAIN" ]; then
    echo "Error: You have to specify a domain name."
else
    set | grep -e "^\(VOLUME\|DOMAIN\|CLIENT\)=" > $CONFIG
    echo "Configuration written to \"$CONFIG\"."
    echo "---------------------------------------"
    cat $CONFIG
fi
