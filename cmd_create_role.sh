#!/usr/bin/env bash

ansible-playbook -i workstation_host create-group-local.yml -e "core_path=$(pwd)" -e "role_name=${1}"