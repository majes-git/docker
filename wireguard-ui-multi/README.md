# wireguard-ui-multi

Spin up multiple instances of wireguard-ui and integrate them with Traefik for https proxying.

## Setup

wireguard-ui-multi requires a patched wireguard-ui Docker image, which can be prepared as follows:

```
$ cd /srv/docker/containers
$ git clone git@github.com:majes-git/docker.git .
$ cd wireguard-ui-multi
$ git clone https://github.com/EmbarkStudios/wg-ui.git
$ cd wg-ui
$ patch -i ../server.go.diff
$ docker build -t mjeschke/wireguard-ui:patched -f UserSpace.Dockerfile .
```

## Configuration

You need a `sites.yaml` file to generate a docker-compose configuration. A sample file may look like this:

```
$ cd /srv/docker/containers/wireguard-ui-multi
$ cat > sites.yaml <<EOF
domain: example.com
sites:
- name: berlin
  net: 192.168.178.0/24
  id: 1
  admin_pass: $(echo secret | ./generate_password_hash.pyz -s)
- name: hamburg
  net: 192.168.2.0/24
  id: 2
  admin_pass: $(echo hello | ./generate_password_hash.pyz -s)
EOF
$ python3 generate_sites.py
$ docker compose up
```

