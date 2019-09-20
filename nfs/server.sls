{% from "nfs/map.jinja" import nfs with context %}

{% if nfs.pkgs_server %}
nfs-server-deps:
    pkg.installed:
        - pkgs: {{ nfs.pkgs_server|json }}
{% endif %}

nfs-exports-configure:
  file.managed:
    - name: {{ nfs.exports_file }}
    - source: {{ nfs.export_template }}
    - template: jinja
    - watch_in:
      - service: nfs-service

{%- if nfs.force_ports is defined and grains.get('os_family') == 'RedHat' %}
nfs-force-ports:
  file.managed:
    - name: {{ nfs.nfs_server_sysconf_file }}
    - source: {{ nfs.nfs_server_sysconf_template }}
    - template: jinja
    - watch_in:
      - service: nfs-service
{%- endif %}

nfs-service:
  service.running:
{% if nfs.service_name is string %}
    - name: {{ nfs.service_name }}
{% elif nfs.service_name is iterable %}
    - names: {{ nfs.service_name }}
{% endif %}
    - enable: True

{% if grains.get('os') == 'FreeBSD' %}
  {% set mountd_flags = salt['pillar.get'](
        'nfs:server:mountd_flags', None) -%}
  {% if mountd_flags %}
mountd_flags:
  sysrc.managed:
    - value: {{ mountd_flags }}
  {% endif %}
{% endif %}
