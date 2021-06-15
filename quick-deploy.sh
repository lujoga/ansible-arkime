#!/bin/bash

set -e

genpass() {
	tr -dc '[:alnum:]' < /dev/urandom | head -c 64
}

if [ -z "$1" ] || [ -z "$2" ]
then
	echo "usage: $0 <target host> <interface...>" >&2
	exit 1
fi

TARGET="$1"
shift 1

if [ -n "$SSH_USER" ]
then
	AUTH=(-u "'$SSH_USER'" -b -K)
else
	AUTH=(-u root)
fi

ELASTICSEARCH="${ELASTICSEARCH:-system}"
INTERFACES="$(python3 -c 'from sys import argv; from json import dumps; print(dumps(argv[1:]))' "$@")"
MOLOCH_PASSWORD="$(genpass)"

export ANSIBLE_NOCOWS="yes"
export ANSIBLE_PIPELINING="yes"
export ANSIBLE_PYTHON_INTERPRETER="auto"
ansible-playbook -i "$TARGET," "${AUTH[@]}" --extra-vars '{"arkime_elasticsearch":"'"$ELASTICSEARCH"'","arkime_interfaces":'"$INTERFACES"',"arkime_password":"'"$(genpass)"'","arkime_initial_user":{"id":"moloch","name":"Moloch","password":"'"$MOLOCH_PASSWORD"'"}}' site.yml

echo "Password for 'moloch': $MOLOCH_PASSWORD" >&2
