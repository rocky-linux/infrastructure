# The URL through which GitLab will be accessed.
external_url "{{ gitlab_external_url }}"

# gitlab.yml configuration
gitlab_rails['time_zone'] = "{{ gitlab_time_zone }}"
gitlab_rails['backup_keep_time'] = {{ gitlab_backup_keep_time }}
gitlab_rails['gitlab_email_enabled'] = {{ gitlab_email_enabled }}
{% if gitlab_email_enabled == "true" %}
gitlab_rails['gitlab_email_from'] = "{{ gitlab_email_from }}"
gitlab_rails['gitlab_email_display_name'] = "{{ gitlab_email_display_name }}"
gitlab_rails['gitlab_email_reply_to'] = "{{ gitlab_email_reply_to }}"
{% endif %}

# Default Theme
gitlab_rails['gitlab_default_theme'] = "{{ gitlab_default_theme }}"

# Whether to redirect http to https.
nginx['redirect_http_to_https'] = {{ gitlab_redirect_http_to_https }}
nginx['ssl_certificate'] = "{{ gitlab_ssl_certificate }}"
nginx['ssl_certificate_key'] = "{{ gitlab_ssl_certificate_key }}"

# The directory where Git repositories will be stored.
git_data_dirs({"default" => {"path" => "{{ gitlab_git_data_dir }}"} })

# The directory where Gitlab backups will be stored
gitlab_rails['backup_path'] = "{{ gitlab_backup_path }}"

# These settings are documented in more detail at
# https://gitlab.com/gitlab-org/gitlab-ce/blob/master/config/gitlab.yml.example#L118
gitlab_rails['ldap_enabled'] = {{ gitlab_ldap_enabled }}
{% if gitlab_ldap_enabled == "true" %}
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS'
  main:
    label: 'LDAP'
    host: '{{ gitlab_ldap_host }}'
    port: {{ gitlab_ldap_port  }}
    uid: '{{ gitlab_ldap_uid }}'
    method: '{{ gitlab_ldap_method}}'
    bind_dn: '{{ gitlab_ldap_bind_dn }}'
    password: '{{ gitlab_ldap_password }}'
    allow_username_or_email_login: true
    base: '{{ gitlab_ldap_base }}'
    user_filter: '{{ gitlab_ldap_user_filter }}'
    group_base: '{{ gitlab_ldap_group_dn }}'
    admin_group: '{{ gitlab_ldap_admin_group }}'
    sync_ssh_keys: true
    attributes:
      username: ['uid']
      email: ['mail']
      name: 'cn'
      first_name: 'givenName'
      last_name: 'sn'
EOS
{% endif %}

# GitLab Nginx
## See https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/settings/nginx.md
{% if gitlab_nginx_listen_port is defined %}
nginx['listen_port'] = "{{ gitlab_nginx_listen_port }}"
{% endif %}
{% if gitlab_nginx_listen_https is defined %}
nginx['listen_https'] = {{ gitlab_nginx_listen_https }}
{% endif %}

# Use smtp instead of sendmail/postfix
# More details and example configuration at
# https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/doc/settings/smtp.md
gitlab_rails['smtp_enable'] = {{ gitlab_smtp_enable }}
{% if gitlab_smtp_enable == "true" %}
gitlab_rails['smtp_address'] = '{{ gitlab_smtp_address }}'
gitlab_rails['smtp_port'] = {{ gitlab_smtp_port }}
{% if gitlab_smtp_user_name %}
gitlab_rails['smtp_user_name'] = '{{ gitlab_smtp_user_name }}'
{% endif %}
{% if gitlab_smtp_password %}
gitlab_rails['smtp_password'] = '{{ gitlab_smtp_password }}'
{% endif %}
gitlab_rails['smtp_domain'] = '{{ gitlab_smtp_domain }}'
{% if gitlab_smtp_authentication %}
gitlab_rails['smtp_authentication'] = '{{ gitlab_smtp_authentication }}'
{% endif %}
gitlab_rails['smtp_enable_starttls_auto'] = {{ gitlab_smtp_enable_starttls_auto }}
gitlab_rails['smtp_tls'] = {{ gitlab_smtp_tls }}
gitlab_rails['smtp_openssl_verify_mode'] = '{{ gitlab_smtp_openssl_verify_mode }}'
gitlab_rails['smtp_ca_path'] = '{{ gitlab_smtp_ca_path }}'
gitlab_rails['smtp_ca_file'] = '{{ gitlab_smtp_ca_file }}'
{% endif %}

# 2-way SSL Client Authentication.
{% if gitlab_nginx_ssl_verify_client %}
nginx['ssl_verify_client'] = "{{ gitlab_nginx_ssl_verify_client }}"
{% endif %}
{% if gitlab_nginx_ssl_client_certificate %}
nginx['ssl_client_certificate'] = "{{ gitlab_nginx_ssl_client_certificate }}"
{% endif %}

# GitLab registry.
registry['enable'] = {{ gitlab_registry_enable }}
{% if gitlab_registry_enable == "true" %}
registry_external_url "{{ gitlab_registry_external_url }}"
registry_nginx['ssl_certificate'] = "{{ gitlab_registry_nginx_ssl_certificate }}"
registry_nginx['ssl_certificate_key'] = "{{ gitlab_registry_nginx_ssl_certificate_key }}"
{% endif %}

{% if gitlab_extra_settings is defined %}
# Extra configuration
{% for extra in gitlab_extra_settings %}
{% for setting in extra %}
{% for kv in extra[setting] %}
{% if (kv.type is defined and kv.type == 'plain') or (kv.value is not string) %}
{{ setting }}['{{ kv.key }}'] = {{ kv.value }}
{% else %}
{{ setting }}['{{ kv.key }}'] = '{{ kv.value }}'
{% endif %}
{% endfor %}
{% endfor %}

{% endfor %}
{% endif %}

# To change other settings, see:
# https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md#changing-gitlab-yml-settings
nginx['enable'] = false
nginx['external_users'] = ['nginx']

{% if gitlab_external_db %}
postgresql['enable'] = false
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'unicode'
gitlab_rails['db_host'] = '{{ gitlab_external_db_host }}'
gitlab_rails['db_port'] = '{{ gitlab_external_db_port }}'
gitlab_rails['db_username'] = '{{ gitlab_external_db_user }}'
gitlab_rails['db_password'] = '{{ gitlab_external_db_password }}'
{% endif %}
