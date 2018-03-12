# 3 tier app for the ansible tower course.
This is copied from the lab7 project to get all the artefacts in the
root where Ansible Tower is expecting the files to be and also
to be able to change the files to run from tower.

This is the QA branch that will deploy on Openstack. 

# Documentation

The application assumes that ansible tower has been set up.

There are a set of convenience scripts set up to use with the provisoning scripts.

# Provision 

* Create networks
course-redhat-ansible-windows-chapter7/code/provisioning-QA/cmd_create_networks.sh
(Includes router)

  * Calls: pb_create_network.yml

* Create keypair
course-redhat-ansible-windows-chapter7/code/provisioning-QA/cmd_create_sshkeys.sh
  * Calls: pb_sshkeys.yml

* Create flavor
course-redhat-ansible-windows-chapter7/code/provisioning-QA/cmd_create_flavor.sh
  * Calls: pb_osp_flavor.yml 

* Create the security groups
course-redhat-ansible-windows-chapter7/code/provisioning-QA/cmd_create_security.sh
  * Calls: pb_setup_security.yml

* Build instances
course-redhat-tower-os-3tier/cmd_create_instances.sh
  * Calls: pb_create_instances.yml
  
* Install apps
course-redhat-tower-os-3tier/cmd_install_applications.sh
  * Calls: pb_install_apps.yml

* Delete instances
course-redhat-tower-os-3tier/cmd_delete_instances.sh
  * Calls: pb_delete_instances.yml
  
The ansible tower instances will create and delete the servers but will not recreate the infrastructure, though
these are also created by ansible.
  