#!/usr/bin/env bash
source ./set-env.sh
ansible-playbook -i workstation_host provision-workstation.yml -e "guid=${GUID}"