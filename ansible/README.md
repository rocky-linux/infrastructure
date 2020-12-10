# Ansible

Ansible playbooks, roles, modules, etc will come here. Documentation to come soon.

Each playbook should have comments or a name descripter that explains what the playbook does or how it is used. If not available, README-... files can be used in place.

## Management Node Structure

Loosely copied from the CentOS ansible infrastructure. This structure is represented in this repository.

```
.
├── ansible.cfg
├── files -> playbooks/files
├── handlers -> playbooks/handlers
├── inventory
├── pkistore
├── playbooks
│   ├── files
│   ├── group_vars
│   ├── host_vars
│   ├── handlers
│   ├── tasks
│   ├── templates
│   ├── vars
│   └── requirements.yml
├── roles
│   └── <role-name>
├── tasks -> playbooks/tasks
├── templates -> playbooks/templates
└── vars -> playbooks/vars
```

## Structure

What each folder represents

```
files      -> As the name implies, non-templated files go here
group_vars -> Group Variables go here if they are not fulfilled in an inventory
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
import -> Playbooks that should be imported from the top level playbooks
role-* -> These playbooks call roles specifically for infrastructure tasks.
          Playbooks that do not call a role should be named init or adhoc based
          on their usage.
adhoc  -> These playbooks are one-off playbooks that can be used on the CLI or
          in AWX
```

## Designing Playbooks

### Pre flight and post flight

At a minimum, there should be `pre_tasks` and `post_tasks` that can judge whether ansible has been can or has been run on a system. Some playbooks will not necessarily need this (eg if you're running an adhoc playbook to create a user). But operations done on a host should at least have these in the playbook.

```
  pre_tasks:
    - name: Check if ansible cannot be run here
      stat:
        path: /etc/no-ansible
      register: no_ansible

    - name: Verify if we can run ansible
      assert:
        that:
          - "not no_ansible.stat.exists"
        msg: "/etc/no-ansible exists - skipping run on this node"

  # Import roles/tasks here

  post_tasks:
    - name: Touching run file that ansible has ran here
      file:
        path: /var/log/ansible.run
        state: touch
```

If you need to use handlers, you will need to include them in the playbook.

### Roles

If you are using roles that are not part of this repository in the `roles` directory, you will need to list them in the `requirements.yml`. For example, we use the IPA role.

```
---
- src: freeipa.ansible_freeipa
```

Otherwise, custom roles for the infrastructure will sit in `ansible/roles`.
