#!/bin/sh

# init
ip link add wg0 type wireguard
ip address add dev wg0 ${IP_ADDRESS}
echo "${PRIVATE_KEY}" > /private_key
chmod 0400 /private_key

# prepare peers
PEERS_COMMAND="listen-port 51820"
for PEER in ${PEERS}; do
    ADDRESS=$(echo ${PEER} | awk -F: '{ print $1 }')
    PUBLIC_KEY=$(echo ${PEER} | awk -F: '{ print $2 }')
    PEERS_COMMAND="${PEERS_COMMAND} peer ${PUBLIC_KEY} allowed-ips ${ADDRESS}"
    if [ -n "${KEEPALIVE}" ]; then PEERS_COMMAND="${PEERS_COMMAND} persistent-keepalive ${KEEPALIVE}"; fi
    if [ -n "${ENDPOINT}" ]; then PEERS_COMMAND="${PEERS_COMMAND} endpoint ${ENDPOINT}"; break; fi
done

# set up wireguard environment
wg set wg0 private-key /private_key ${PEERS_COMMAND}
ip link set up dev wg0
${IPTABLES}

# do not stop the container when script is done
sleep infinity

