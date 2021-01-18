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
