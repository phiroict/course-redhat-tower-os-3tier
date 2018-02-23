#!/usr/bin/env bash

ansible-playbook -i workstation_host provision-workstation.yml -e "guid=${GUID}"