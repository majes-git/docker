#!/usr/bin/env python3

from string import Template
import sys
import yaml

IMAGE = 'mjeschke/wireguard-ui:patched'


def error(*msg):
    print(*msg)
    sys.exit(1)


def load_sites(filename='sites.yaml'):
    with open(filename) as fd:
        return yaml.safe_load(fd)


def load_template(filename='docker-compose.template'):
    with open(filename) as fd:
        return Template(fd.read())


def populate_site_parameters(site, domain='example.com', vpn='vpn1'):
    id = site['id']
    site_name = site['name']
    site.update({
      'image': IMAGE,
      'vpn_endpoint': f'{site_name}.{vpn}.{domain}',
      'vpn_port': '518{:02d}'.format(id),
      'vpn_net': f'172.30.{id}.0/24',
    })
    return site


def write_site_config(payload, append=False, filename='docker-compose.override.yaml'):
    mode = 'a' if append else 'w'
    with open(filename, mode) as fd:
        if not append:
            fd.write('services:\n\n')
        return fd.write(payload)


def main():
    template = load_template()
    parameters = load_sites()
    if not parameters:
        error('sites.yaml is empty')
    domain = parameters.get('domain')
    sites = parameters.get('sites')
    if not sites:
        error('sites.yaml does not contain a site')

    append = False
    for site in parameters.get('sites'):
        print(site.get('name'))
        site = populate_site_parameters(site, domain)
        site_config = template.safe_substitute(**site)
        # if no extra net is configured (tunnelbroker mode), remove variable
        site_config = site_config.replace(',$net', '')
        write_site_config(site_config, append)
        append = True


if __name__ == '__main__':
    main()
