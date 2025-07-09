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


def load_local_options(filename='local_options.yaml'):
    local_options = {
        'vpn': 'vpn1',
        'vpn_net': '172.30.{}.0/24',
        'tls': True,
    }
    try:
        with open(filename) as fd:
            local_options.update(yaml.safe_load(fd))
    except FileNotFoundError:
        pass
    return local_options


def load_template(filename='docker-compose.template'):
    with open(filename) as fd:
        return Template(fd.read())


def populate_site_parameters(site, domain, vpn, vpn_net):
    id = site['id']
    site_name = site['name']
    site.update({
      'image': IMAGE,
      'vpn_endpoint': f'{site_name}.{vpn}.{domain}',
      'vpn_port': '518{:02d}'.format(id),
      'vpn_net': vpn_net.format(id),
    })
    return site


def write_site_config(payload, append=False, filename='docker-compose.override.yaml'):
    mode = 'a' if append else 'w'
    with open(filename, mode) as fd:
        if not append:
            fd.write('services:')
        fd.write('\n\n')
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
    local_options = load_local_options()

    append = False
    for site in parameters.get('sites'):
        print(site.get('name'))
        site = populate_site_parameters(site, domain, local_options['vpn'], local_options['vpn_net'])
        site_config = template.safe_substitute(**site)
        # if no extra net is configured (tunnelbroker mode), remove variable
        site_config = site_config.replace(',$net', '')
        if not local_options['tls']:
            site_config_lines = site_config.splitlines()
            for line in site_config_lines.copy():
                if 'tls' in line:
                    site_config_lines.remove(line)
            site_config = '\n'.join(site_config_lines)
        write_site_config(site_config, append)
        append = True


if __name__ == '__main__':
    main()
