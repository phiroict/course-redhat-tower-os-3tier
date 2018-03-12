#!/usr/bin/env bash
source ./set-env.sh
ansible-playbook -i hosts_tower pb_installation_script_at.yml -e "guid=${GUID}"

