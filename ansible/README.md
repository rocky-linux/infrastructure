# Ansible

Ansible playbooks, roles, modules, etc will come here. This wiki will reflect the layout, structure, and potential standards that should be followed when making playbooks and roles.

Each playbook should have comments or a name descriptor that explains what the playbook does or how it is used. If not available, README-... files can be used in place, especially in the case of adhoc playbooks that take input. Documentation for each playbook/role does not have to be on this wiki. Comments or README's should be sufficient.

## Management Node Structure

Loosely copied from the CentOS ansible infrastructure.

```
.
├── ansible.cfg
├── collections
├── files -> playbooks/files
├── handlers -> playbooks/handlers
├── inventories
│   ├── production
│   |   ├── group_vars
│   |   ├── host_vars
│   |   hosts
│   ├── staging
│   ├── devellopment
├── pkistore
├── playbooks
│   ├── files
│   ├── handlers
│   ├── tasks
│   ├── templates
│   ├── vars
├── roles/local
│   └── <role-name>
│   └── requirements.yml
├── tasks -> playbooks/tasks
├── templates -> playbooks/templates
└── vars -> playbooks/vars
```

## Structure

What each folder represents

```
files      -> As the name implies, non-templated files go here. Files that are
              dropped somewhere on the file system should be laid out in a way
              that represents the file system (eg. ./etc/sysconfig/)
group_vars -> Group Variables go here if they are not fulfilled in an inventory.
              Recommended that group_vars be used over inventory vars.
host_vars  -> Host variables go here
inventory  -> All static inventories go here
roles      -> Custom roles can go here
tasks      -> Common tasks come here
templates  -> Templates go here
vars       -> Global variables that are called with vars_files go here. This
```

## Current Playbook Naming

```
init-* -> Starting infrastructure playbooks that run solo or import other
          playbooks that start with import-
adhoc  -> These playbooks are one-off playbooks that can be used on the CLI or
          in AWX. These are typically for basic tasks.
import -> Playbooks that should be imported from the top level playbooks
role-* -> These playbooks call roles specifically for infrastructure tasks.
          Playbooks that do not call a role should be named init or adhoc based
          on their usage.
```

## Ansible Configuration

The ansible configuration declares our defaults for our ansible host. This is especially true for the "destinations", where the roles and collections are referenced.

## Designing Playbooks

### Pre flight and post flight

At a minimum, there should be `pre_tasks` and `post_tasks` that can judge whether ansible can or has been run on a system. Some playbooks will not necessarily need this (eg if you're running an adhoc playbook to create a user). But operations done on a host should at least have these in the playbook, with an optional `handlers:` include.

```
  handlers:
    - include: handlers/main.yml

  pre_tasks:
    - name: Check if ansible cannot be run here
      stat:
        path: /etc/no-ansible
      register: no_ansible

    - name: Verify if we can run ansible
      assert:
        that:
          - "not no_ansible.stat.exists"
        success_msg: "We are able to run on this node"
        fail_msg: "/etc/no-ansible exists - skipping run on this node"

  # Import roles/tasks here

  post_tasks:
    - name: Touching run file that ansible has ran here
      file:
        path: /var/log/ansible.run
        state: touch
        mode: '0644'
        owner: root
        group: root
```

### Comments

Each playbook should have comments or a name descriptor that explains what the playbook does or how it is used. If not available, README-... files can be used in place, especially in the case of adhoc playbooks that take input. Documentation for each playbook/role does not have to be on this wiki. Comments or README's should be sufficient.

### Tags

Ensure that you use relevant tags where necessary for your tasks.

### Roles

If you are using roles or collections, you will need to list them in `./roles/requirements.yml`. For example, we use the `freeipa` collection and a `mysql` role from `geerlingguy`.

```
---
roles:
  - name: geerlingguy.mysql

collections:
  - name: freeipa.ansible_freeipa
    version: 0.3.1
```

**Note**: There will be cases where you should and must specify the version you're working with, depending on the author and the amount of changes that may occur. There may be a future policy that you have to lock onto a specific version.

Custom roles for infrastructure use will have their own separate repository. Right now, we do not have a Ansible Galaxy presence. For this, when referencing roles under Rocky Linux, you will have to specify its location and follow the naming format. Example below.

```
roles:
  - name: rockylinux.ipsilon
    src: https://github.com/rocky-linux/ansible-role-ipsilon
    version: main
```

### There's no role for...

If you have to make your own role, that's understandable. There's going to be cases like this and we would like to try to work on that case by case. If you're going to create your own role, the following things must be true:

* Follows the ansible-galaxy spec
* pre-commit runs for linting purposes
* Molecule github workflow
* The repository name following the format: ansible-role-name

The pre-commit, yamllint, and ansible-lint configurations of this repository is a good starting point for your role.

Right now, this is a good template to start with: https://github.com/Darkbat91/ansible-roletemplate - This will soon be under the rocky-linux umbrella.

### Pre-commits / linting

When pushing to your own forked version of this repository, pre-commit must run to verify your changes. They must be passing to be pushed up. This is an absolute requirement, even for roles.

When the linter passes, the push will complete and you will be able to open a PR.

## Initializing the Ansible Host

When initializing the ansible host, you should be in `./infrastructure/ansible` so that the `ansible.cfg` is used. You will need to run the `init-rocky-ansible-host.yml` playbook and to get started, which will install all the roles and collections required for the playbooks to run.

```
% git clone https://github.com/rocky-linux/infrastructure
% cd infrastructure/ansible
% ansible-playbook playbooks/init-rocky-ansible-host.yml
```

## Initializing the environment

To get a base environment, you will need to run the playbooks in this order.

```
# Ansible host
init-rocky-ansible-host.yml
# First IPA server
role-rocky-ipa.yml
# Replicas
role-rocky-ipa-replica.yml
# Base users, groups, and DNS
init-rocky-ipa-team.yml
init-rocky-ipa-internal-dns.yml
# All clients should be listed under [ipaclients]
role-rocky-ipa-client.yml
# All systems should be hardened
init-rocky-system-config.yml
```

## Current Set

```
.
├── README.md
├── ansible.cfg
├── collections
│   └── Readme.md
├── files -> playbooks/files
├── handlers -> playbooks/handlers
├── inventories
│   ├── production
│   │   ├── group_vars
│   │   │   ├── chronyservers
│   │   │   │   └── main.yml
│   │   │   ├── ipa
│   │   │   │   └── main.yml
│   │   │   ├── ipaclients
│   │   │   │   └── main.yml
│   │   │   ├── ipareplicas
│   │   │   │   └── main.yml
│   │   │   ├── ipaserver
│   │   │   │   └── main.yml
│   │   │   └── rabbitmq
│   │   │       └── main.yml
│   │   └── hosts.ini
│   └── staging
│       ├── group_vars
│       │   ├── chronyservers
│       │   │   └── main.yml
│       │   ├── ipa
│       │   │   └── main.yml
│       │   ├── ipaclients
│       │   │   └── main.yml
│       │   ├── ipareplicas
│       │   │   └── main.yml
│       │   ├── ipaserver
│       │   │   └── main.yml
│       │   └── rabbitmq
│       │       └── main.yml
│       └── hosts.ini
├── playbooks
│   ├── adhoc-facts-refresh.yml
│   ├── adhoc-ipabinder.yml
│   ├── adhoc-ipadnsrecord.yml
│   ├── adhoc-ipadnszone.yml
│   ├── adhoc-ipagetcert.yml
│   ├── adhoc-ipagetkeytab.yml
│   ├── adhoc-ipagroup.yml
│   ├── adhoc-ipaservice.yml
│   ├── adhoc-ipauser-disable.yml
│   ├── adhoc-ipauser-enable.yml
│   ├── adhoc-ipauser.yml
│   ├── adhoc-rabbitmqqueue.yml
│   ├── adhoc-rabbitmquser.yml
│   ├── files
│   │   ├── etc
│   │   │   ├── authselect
│   │   │   │   └── custom
│   │   │   │       └── sssd-rocky
│   │   │   │           ├── CentOS-8-system-auth -> RedHat-8-system-auth
│   │   │   │           └── RedHat-8-system-auth
│   │   │   ├── gitlab
│   │   │   ├── pam.d
│   │   │   │   ├── CentOS-7-system-auth-ac -> RedHat-7-system-auth-ac
│   │   │   │   └── RedHat-7-system-auth-ac
│   │   │   ├── rockybanner
│   │   │   └── sudoers.d
│   │   │       └── cis
│   │   ├── tmp
│   │   └── usr
│   │       └── local
│   │           └── bin
│   │               └── lock-wrapper
│   ├── handlers
│   │   └── main.yml
│   ├── import-rockygroups.yml
│   ├── import-rockyipaprivs.yml
│   ├── import-rockypwpolicy.yml
│   ├── import-rockysudo.yml
│   ├── import-rockyusers.yml
│   ├── init-rocky-account-services.yml
│   ├── init-rocky-ansible-host.yml
│   ├── init-rocky-bugzilla.yml
│   ├── init-rocky-builder-postfix.yml
│   ├── init-rocky-chrony.yml
│   ├── init-rocky-install-kvm-hosts.yml
│   ├── init-rocky-ipa-internal-dns.yml
│   ├── init-rocky-ipa-team.yml
│   ├── init-rocky-noggin-theme.yml
│   ├── init-rocky-system-config.yml
│   ├── rocky-rocky-gitlab-ee.yml
│   ├── role-rocky-graylog.yml
│   ├── role-rocky-ipa-client.yml
│   ├── role-rocky-ipa-replica.yml
│   ├── role-rocky-ipa.yml
│   ├── role-rocky-ipsilon.yml
│   ├── role-rocky-kojid.yml
│   ├── role-rocky-kojihub.yml
│   ├── role-rocky-monitoring.yml
│   ├── role-rocky-mqtt.yml
│   ├── role-rocky-node_exporter.yml
│   ├── role-rocky-rabbitmq.yml
│   ├── role-rocky-sigul-bridge.yml
│   ├── role-rocky-sigul-server.yml
│   ├── tasks
│   │   ├── account_services.yml
│   │   ├── auditd.yml
│   │   ├── authentication.yml
│   │   ├── chrony.yml
│   │   ├── gitlab-reconfigure.yml
│   │   ├── grub.yml
│   │   ├── harden.yml
│   │   ├── koji_efs.yml
│   │   ├── main.yml
│   │   ├── mantis.yml
│   │   ├── postfix_relay.yml
│   │   ├── rabbitmq-reconfigure.yml
│   │   ├── scripts.yml
│   │   ├── ssh_config.yml
│   │   └── variable_loader_common.yml
│   ├── templates
│   │   ├── etc
│   │   │   ├── audit
│   │   │   │   └── rules.d
│   │   │   │       └── collection.rules.j2
│   │   │   ├── chrony.conf.j2
│   │   │   ├── gitlab
│   │   │   │   └── rocky_gitlab.rb
│   │   │   ├── httpd
│   │   │   │   └── conf.d
│   │   │   │       ├── id.conf.j2
│   │   │   │       └── mantis.conf.j2
│   │   │   ├── modprobe.d
│   │   │   │   └── cis.conf.j2
│   │   │   ├── nginx
│   │   │   │   ├── conf.d
│   │   │   │   │   └── omnibus.conf.j2
│   │   │   │   └── nginx.conf.j2
│   │   │   ├── postfix
│   │   │   │   └── sasl_passwd.j2
│   │   │   ├── resolv.conf.j2
│   │   │   ├── rsyslog.d
│   │   │   ├── ssh
│   │   │   │   ├── CentOS-7-sshd_config.j2 -> RedHat-7-sshd_config.j2
│   │   │   │   ├── CentOS-8-sshd_config.j2 -> RedHat-8-sshd_config.j2
│   │   │   │   ├── RedHat-7-sshd_config.j2
│   │   │   │   └── RedHat-8-sshd_config.j2
│   │   │   └── sssd
│   │   ├── hidden
│   │   │   ├── README.md
│   │   │   └── home
│   │   │       └── noggin
│   │   │           └── noggin.cfg
│   │   ├── tmp
│   │   │   ├── binder.update
│   │   │   └── binder_template.update
│   │   └── var
│   │       └── www
│   │           └── mantis
│   │               └── config
│   │                   └── config_inc.php.j2
│   └── vars
│       ├── CentOS.yml -> RedHat.yml
│       ├── RedHat.yml
│       ├── buildsys.yml
│       ├── chrony.yml
│       ├── chronyserver.yml
│       ├── common.yml
│       ├── gitlab.yml
│       ├── graylog.yml
│       ├── ipa
│       │   ├── adminusers.yml
│       │   ├── agreements.yml
│       │   ├── fdns.yml
│       │   ├── groups.yml
│       │   ├── ipaclient.yml
│       │   ├── ipaprivs.yml
│       │   ├── ipareplica.yml
│       │   ├── ipaserver.yml
│       │   ├── rdns.yml
│       │   ├── sudorules.yml
│       │   ├── svcusers.yml
│       │   └── users.yml
│       ├── ipaserver.yml
│       ├── ipsilon.yml
│       ├── koji-common.yml
│       ├── kojid.yml
│       ├── kojihub.yml
│       ├── mantis.yml
│       ├── matterbridge.yml
│       ├── monitoring
│       │   └── README.md
│       ├── monitoring.yml
│       ├── mqtt.yml
│       ├── rabbitmq.yml
│       ├── sigul_bridge.yml
│       ├── sigul_server.yml
│       └── vaults
│           └── README.md
├── roles
│   ├── local
│   │   └── Readme.md
│   ├── public
│   │   └── Readme.md
│   └── requirements.yml
├── ssh_config
├── tasks -> playbooks/tasks
├── templates -> playbooks/templates
├── tmp
│   ├── Readme.md
│   └── ansible.log
└── vars -> playbooks/vars
```
