#!/bin/bash

/bin/cp "{{ gitlab_ssl_key }}" /etc/gitlab/ssl/
/bin/cp "{{ gitlab_ssl_cert }}" /etc/gitlab/ssl/
/bin/chown gitlab-www /etc/gitlab/ssl/*.{crt,key}
/bin/chmod 600 /etc/gitlab/ssl/*.key
/usr/bin/gitlab-ctl hup nginx
