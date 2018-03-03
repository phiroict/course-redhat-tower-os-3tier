# Ansible tower setup.
Using the OTLC-LAB-philip.rodrigues-solnet.co.nz-PROD_ANS_TOWER_LAB-c586 as template.



# Inventory file
```
[tower]
tower1.c586.internal
tower2.c586.internal
tower3.c586.internal


[database]
support1.c586.internal
[all:vars]
ansible_become=true
admin_password='r3dh4t1!'

pg_host='support1.${GUID}.internal'
pg_port='5432'

pg_database='awx'
pg_username='awx'
pg_password='r3dh4t1!'

rabbitmq_port=5672
rabbitmq_vhost=tower

rabbitmq_username=tower
rabbitmq_password='r3dh4t1!'
rabbitmq_cookie=cookiemonster

rabbitmq_use_long_name=true


```
# Setting up a license:
```json
{
    "company_name": "Red Hat Internal",
    "contact_email": "ber@redhat.com",
    "contact_name": "Jon Bersuder",
    "instance_count": 40,
    "license_date": 1522555200,
    "license_key": "140d562b35ec356de3cda5207ba4741281fef469d14d25ec45af520224972acf",
    "license_type": "enterprise",
    "subscription_name": "Ansible Tower by Red Hat, Standard (40 Managed Nodes)",
    "trial": false
}

```

# Setting up replication

```
ansible support1.${GUID}.internal -m lineinfile -a "line='include_dir = 'conf.d'' path=/var/lib/pgsql/9.6/data/postgresql.conf"
```
and
```
ansible support1.${GUID}.internal -m file -a 'path=/var/lib/pgsql/9.6/data/conf.d state=directory'
```
and install cluster config:
```
cat << EOF > tower-postgresql.conf
wal_level = hot_standby
synchronous_commit = local
archive_mode = on
archive_command = 'cp %p /var/lib/pgsql/9.6/data/archive/%f'
max_wal_senders = 2
wal_keep_segments = 10
synchronous_standby_names = 'slave01'
EOF
```

```
ansible support1.${GUID}.internal -m copy -a "src=/root/tower-postgresql.conf dest=/var/lib/pgsql/9.6/data/conf.d/tower-postgresql.conf"
```
Now set the postgresql master to accept slave connections:

```
ansible support1.${GUID}.internal  -m lineinfile -a "line='host    replication replica     0.0.0.0/0        md5' path=/var/lib/pgsql/9.6/data/pg_hba.conf"
```

Bounce the postgres service

```
ansible support1.${GUID}.internal -m service -a"name=postgresql-9.6 state=restarted"
```

Now create a slave user:
```
ansible support1.${GUID}.internal -m postgresql_user -a "name=replica password=r3dh4t1! role_attr_flags=REPLICATION state=present" --become-user=postgres
```

Now install the GPG keys to enable the repos

```
ansible support2.${GUID}.internal -m get_url -a "url=http://www.opentlc.com/download/ansible_bootcamp/repo/pgdg-96-centos.repo dest=/etc/yum.repos.d/pgdg-96-centos.repo"
```

```
ansible support2.${GUID}.internal -m get_url -a "url=http://www.opentlc.com/download/ansible_bootcamp/repo/RPM-GPG-KEY-PGDG-96 dest=/etc/pki/rpm-gpg/RPM-GPG-KEY-PGDG-96"
```

Install postgres on the support2 service:

```
ansible support2.${GUID}.internal -m yum -a "name=postgresql96-server state=present"

```

Replicate the database to the slave

```
ansible support2.${GUID}.internal -m shell -a "export PGPASSWORD=r3dh4t1! && pg_basebackup -h support1.${GUID}.internal -U replica -D /var/lib/pgsql/9.6/data/ -P --xlog" --become-user=postgres
```
Now tell the slave to be the backup server:

```
ansible support2.${GUID}.internal -m lineinfile -a "line='hot_standby = on' path=/var/lib/pgsql/9.6/data/postgresql.conf"
```

Create a recovery config to restore the database:
```
cat << EOF > recovery.conf
restore_command = 'scp support1.${GUID}.internal:/var/lib/pgsql/9.6/data/archive/%f %p'
standby_mode = on
primary_conninfo = 'host=support1.${GUID}.internal port=5432 user=replica password=r3dh4t1! application_name=slave01'
EOF

nsible support2.${GUID}.internal -m copy -a "src=/root/recovery.conf dest=/var/lib/pgsql/9.6/data/recovery.conf"
```

Start and enable the postgres service for the slave

```
ansible support2.${GUID}.internal -m service -a "name=postgresql-9.6 state=started enabled=true"
```

Now check the replication status

```
ansible support1.${GUID}.internal -m shell -a "psql -c 'select application_name, state, sync_priority, sync_state from pg_stat_replication;'" --become-user postgres
```
