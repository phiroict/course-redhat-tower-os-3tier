#!/usr/bin/env bash

ansible-playbook -vv --ask-vault-pass -i osp_jumpbox_inventory  pb_install_apps.yml