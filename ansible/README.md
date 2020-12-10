# Ansible

Ansible playbooks, roles, modules, etc will come here. Documentation to come soon.

Each playbook should have comments or a name descripter that explains what the playbook does or how it is used. If not available, README-... files can be used in place.

## Structure

```
files      -> As the name implies, non-templated files go here
group_vars -> Group Variables go here if they are not fulfilled in an inventory
host_vars  -> Host variables go here
inventory  -> All static inventories go here
roles      -> Custom roles can go here
tasks      -> Common tasks come here
templates  -> Templates go here
vars       -> Global variables that are called with vars_files go here. This
              is mainly for init and encpass.yml
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
