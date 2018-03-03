# Startup
Created git repo at: [Git](https://github.com/phiroict/course-redhat-ansible-lab-assignment.git)

# Requirements

* GitHub repository
* Playbooks to deploy internal three-tier application
* Install HA Ansible Tower

Check lab 5 notes for configuration of openstack and redeploy on a fresh ansible for openstack project


# Restart Openstack services after server restart:
```bash


# from the workstation:
sudo -i
cd /root
source keystonerc_admin
openstack server list
nova start database app1 app2 frontend
openstack server list

```


# Build

We need to set up a new ansible tower on lab5 guid: aa0f.  Ansible tower.
https://tower1.aa0f.example.opentlc.com
And a openstack instance as well : 1db6                    Three tier project.


## Server stack
### Ansible tower stack
Notes:
The keys need to be in the /var/lib/awx/SSH (openstack.pem) in there manually.
Also, you need to have the ssh.cfg and the ansible.cfg in the root of the project, nowhere else.



### Application stack static (not used)


### Application stack openshift for QA
Create with ansible using the os_ modules

### Application stack for AWS for production
Create with ansible using the ec2_ modules.





## Github created at [Git](https://github.com/phiroict/course-redhat-ansible-lab-assignment.git)

## Playbook deploy a three-tier application
Mainly from the lab5 as well. Should pretty well work.

### Provision stack
From lab5 create servers, flavors and all that.

### Deploy application
From the lab5
### Test application
Needs to be written:
* socket check
* response check
* round robin check.

## Install Tower
Installed on the aa0f service so we are going to use that for this assignment

# Steps
From https://labs.opentlc.com/catalog/explorer
* Recreate ansible tower lab project
* Recreate Three tier application project from the catalog.

## provision ansible tower
By script
<git-assignment>/code/ansible-tower/cmd_install_tower.sh

```yaml

---
  - name: Install the installation scripts for ansible and configure database
    hosts: jumphost
    become: yes
    gather_facts: False
    tasks:
      - name: Get installation script
        unarchive:
          src: https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-latest.tar.gz
          dest: /root/
          remote_src: yes
        creates: /root/ansible-tower-setup-3.2.3
      - name: Get the folder name of the installation
        find:
          paths: /root
          patterns: 'ansible-tower-setup-*'
          file_type: directory
        register: find_result
      - name:
        debug:
          msg: "results are {{ find_result.files[0].path }}"
      - name: Copy over inventory file
        template:
          src: ./hosts_tower
          dest: "{{ find_result.files[0].path }}/inventory"
          backup: yes
      - name: Execute installation
        shell: bash setup.sh
        args:
          chdir: "{{ find_result.files[0].path }}"

```



Connect to it by:
https://tower1.765c.example.opentlc.com/#/home
Test: Ok.

## Provision Openstack environment.
* On machine workstation-1db6.rhpds.opentlc.com
Follow instructions setting up from lab5

Copy over keys:
```bash

sudo -i
export GUID=<My GUID>
scp ctrl-${GUID}.rhpds.opentlc.com:/etc/yum.repos.d/open.repo /etc/yum.repos.d/open.repo
yum install python-openstackclient
# Copy the keystonerc_admin file from ctrl.example.com and source it in root's home directory to set environment variables and verify the OpenStack environment:

scp ctrl.example.com:/root/keystonerc_admin /root/
source /root/keystonerc_admin
openstack hypervisor list
```
Returned

```text
+----+---------------------+
| ID | Hypervisor Hostname |
+----+---------------------+
|  1 | comp00.example.com  |
|  2 | comp01.example.com  |
+----+---------------------+
```

Ok

* Now install the keys
```bash
wget http://www.opentlc.com/download/ansible_bootcamp/openstack_keys/openstack.pub
cat openstack.pub  >> /home/cloud-user/.ssh/authorized_keys
```
Note that this will inject it into the cloud-user keystore.
* Install shade
```bash
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install `ls *epel*.rpm`
yum install -y python python-devel python-pip gcc ansible
pip install shade
```

* Install cloud definitions
```bash
workstation# mkdir /etc/openstack
workstation# cat << EOF > /etc/openstack/clouds.yaml
clouds:
  ospcloud:
    auth:
      auth_url: http://192.168.0.20:5000/
      password: r3dh4t1!
      project_name: admin
      username: admin
    identity_api_version: '3.0'
    region_name: RegionOne
ansible:
  use_hostnames: True
  expand_hostvars: False
  fail_on_errors: True
EOF
```
* Install image, from course-redhat-ansible-windows-chapter7/code/provisioning-QA/cmd_read_image.sh but run from the
workstation.
Runs playbook pb_read_image.yml.

* Check oauth connection:
```bash
ansible localhost -m os_auth -a cloud=ospcloud
```
Result : ok

* Build Image
course-redhat-ansible-lab-assignment/code/provisioning-QA/cmd_create_image.sh


* Create networks
course-redhat-ansible-windows-chapter7/code/provisioning-QA/cmd_create_networks.sh
(Includes router)

# Create keypair
course-redhat-ansible-windows-chapter7/code/provisioning-QA/cmd_create_sshkeys.sh

* Create flavor
course-redhat-ansible-windows-chapter7/code/provisioning-QA/cmd_create_flavor.sh

* Create the security groups
course-redhat-ansible-windows-chapter7/code/provisioning-QA/cmd_create_security.sh

* Build instances
course-redhat-ansible-lab-assignment/code/provisioning-QA/cmd_create_instances.sh

* Install apps
course-redhat-ansible-lab-assignment/code/provisioning-QA/cmd_install_applications.sh

* Run the sanity checks


All ok, after forwarding the ports out. 


# Debugging ansible-tower
## Issue, SSH connection to workstation: 
Running job returns:

```text
ansible-playbook 2.4.2.0
  config file = /var/lib/awx/projects/_11__openshift_1db6/ansible.cfg
  configured module search path = [u'/var/lib/awx/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 2.7.5 (default, May  3 2017, 07:55:04) [GCC 4.8.5 20150623 (Red Hat 4.8.5-14)]
Using /var/lib/awx/projects/_11__openshift_1db6/ansible.cfg as config file
setting up inventory plugins
Parsed /tmp/awx_101_tLH8ou/tmp6LBHYM.awxrest.py inventory source with script plugin
Loading callback plugin awx_display of type stdout, v2.0 from /usr/lib/python2.7/site-packages/ansible/plugins/callback/__init__.pyc
PLAYBOOK: pb_demo.yml **********************************************************
1 plays in pb_demo.yml
PLAY [Test to see where this is running] ***************************************
10:17:45
TASK [Gathering Facts] *********************************************************
10:17:45
Using module file /usr/lib/python2.7/site-packages/ansible/modules/system/setup.py
<workstation-1db6.rhpds.opentlc.com> ESTABLISH SSH CONNECTION FOR USER: cloud-user
<workstation-1db6.rhpds.opentlc.com> SSH: EXEC ssh -vvv -F ./ssh.cfg -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no -o 'IdentityFile="/var/lib/awx/.ssh/openstack.pem"' -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o User=cloud-user -o ConnectTimeout=10 -o ControlPath=/tmp/awx_101_tLH8ou/cp/%h%p%r workstation-1db6.rhpds.opentlc.com '/bin/sh -c '"'"'echo ~ && sleep 0'"'"''
<workstation-1db6.rhpds.opentlc.com> (255, '', 'OpenSSH_7.4p1, OpenSSL 1.0.1e-fips 11 Feb 2013\r\ndebug1: Reading configuration data ./ssh.cfg\r\ndebug1: ./ssh.cfg line 1: Applying options for workstation-1db6.rhpds.opentlc.com\r\ndebug2: add_identity_file: ignoring duplicate key /var/lib/awx/.ssh/openstack.pem\r\ndebug1: ./ssh.cfg line 14: Applying options for *\r\ndebug1: auto-mux: Trying existing master\r\ndebug1: Control socket "/tmp/awx_101_tLH8ou/cp/workstation-1db6.rhpds.opentlc.com22cloud-user" does not exist\r\ndebug2: resolving "workstation-1db6.rhpds.opentlc.com" port 22\r\ndebug2: ssh_connect_direct: needpriv 0\r\ndebug1: Connecting to workstation-1db6.rhpds.opentlc.com [85.190.177.237] port 22.\r\ndebug2: fd 3 setting O_NONBLOCK\r\ndebug1: fd 3 clearing O_NONBLOCK\r\ndebug1: Connection established.\r\ndebug3: timeout: 9994 ms remain after connect\r\ndebug1: key_load_public: No such file or directory\r\ndebug1: identity file /var/lib/awx/.ssh/openstack.pem type -1\r\ndebug1: key_load_publi…
fatal: [workstation-1db6.rhpds.opentlc.com]: UNREACHABLE! => {
    "changed": false, 
    "msg": "Failed to connect to the host via ssh: OpenSSH_7.4p1, OpenSSL 1.0.1e-fips 11 Feb 2013\r\ndebug1: Reading configuration data ./ssh.cfg\r\ndebug1: ./ssh.cfg line 1: Applying options for workstation-1db6.rhpds.opentlc.com\r\ndebug2: add_identity_file: ignoring duplicate key /var/lib/awx/.ssh/openstack.pem\r\ndebug1: ./ssh.cfg line 14: Applying options for *\r\ndebug1: auto-mux: Trying existing master\r\ndebug1: Control socket \"/tmp/awx_101_tLH8ou/cp/workstation-1db6.rhpds.opentlc.com22cloud-user\" does not exist\r\ndebug2: resolving \"workstation-1db6.rhpds.opentlc.com\" port 22\r\ndebug2: ssh_connect_direct: needpriv 0\r\ndebug1: Connecting to workstation-1db6.rhpds.opentlc.com [85.190.177.237] port 22.\r\ndebug2: fd 3 setting O_NONBLOCK\r\ndebug1: fd 3 clearing O_NONBLOCK\r\ndebug1: Connection established.\r\ndebug3: timeout: 9994 ms remain after connect\r\ndebug1: key_load_public:…
PLAY RECAP *********************************************************************
10:17:45
workstation-1db6.rhpds.opentlc.com : ok=0    changed=0    unreachable=1    failed=0  
```

Run from commandline from tower1.aa0f as the awx user:
```bash
cd /var/lib/awx/projects/_7__lab_3tier_application
ansible-playbook -vvv -i osp_jumpbox_inventory pb_demo.yml

```
Returns ok:
```text
ansible-playbook 2.4.2.0
  config file = /var/lib/awx/projects/_7__lab_3tier_application/ansible.cfg
  configured module search path = [u'/var/lib/awx/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /bin/ansible-playbook
  python version = 2.7.5 (default, May  3 2017, 07:55:04) [GCC 4.8.5 20150623 (Red Hat 4.8.5-14)]
Using /var/lib/awx/projects/_7__lab_3tier_application/ansible.cfg as config file
Parsed /var/lib/awx/projects/_7__lab_3tier_application/osp_jumpbox_inventory inventory source with ini plugin

...

TASK [Where am I running.] ******************************************************************************************************************************************************************
task path: /var/lib/awx/projects/_7__lab_3tier_application/pb_demo.yml:6
ok: [workstation-1db6.rhpds.opentlc.com] => {
    "msg": "This is host: [u'192.168.0.5']"
}
META: ran handlers
META: ran handlers
...

```
The result matches the ip of the jumphost
```text
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 2c:c2:60:48:bd:62 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.5/24 brd 192.168.0.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::2ec2:60ff:fe48:bd62/64 scope link 
       valid_lft forever preferred_lft forever

```

The commandline runs this ssh command on gathering facts compared with the one tower is using: 
```text

<workstation-1db6.rhpds.opentlc.com> SSH: EXEC ssh -F ./ssh.cfg -o ControlMaster=auto -o ControlPersist=60s -o 'IdentityFile="/var/lib/awx/.ssh/openstack.pem"' -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o User=cloud-user -o ConnectTimeout=10 -o ControlPath=/var/lib/awx/.ansible/cp/40c670be5d workstation-1db6.rhpds.opentlc.com '/bin/sh -c '"'"'echo ~ && sleep 0'"'"''
<workstation-1db6.rhpds.opentlc.com> SSH: EXEC ssh -F ./ssh.cfg -o ControlMaster=auto -o ControlPersist=60s -o 'IdentityFile="/var/lib/awx/.ssh/openstack.pem"' -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o User=cloud-user -o ConnectTimeout=10 -o ControlPath=/tmp/awx_101_tLH8ou/cp/%h%p%r workstation-1db6.rhpds.opentlc.com -o StrictHostKeyChecking=no '/bin/sh -c '"'"'echo ~ && sleep 0'"'"''
```

Ansible-towlet runs:

```text
<workstation-1db6.rhpds.opentlc.com> SSH: EXEC ssh -vvv -F ./ssh.cfg -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no -o 'IdentityFile="/var/lib/awx/.ssh/openstack.pem"' -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o User=cloud-user -o ConnectTimeout=10 -o ControlPath=/tmp/awx_101_tLH8ou/cp/%h%p%r workstation-1db6.rhpds.opentlc.com '/bin/sh -c '"'"'echo ~ && sleep 0'"'"''
```