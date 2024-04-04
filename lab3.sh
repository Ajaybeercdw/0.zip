#!/bin/bash
VERBOSE_MODE=""
if [ "$1" = "-verbose" ]; then
    VERBOSE_MODE="-verbose"
fi

deploy_and_configure() {
    server_name=$1
    host_name=$2
    ip_addr=$3
    peer_host=$4
    peer_ip=$5
    
    scp configure-host_v1.sh "remoteadmin@${server_name}-mgmt:/root"
    ssh "remoteadmin@${server_name}-mgmt" -- /root/configure-host_v1.sh $VERBOSE_MODE -n "$host_name" -i "$ip_addr" -he "$peer_host" "$peer_ip"
}

# Configure server1 and server2 with their respective settings
deploy_and_configure server1 loghost 192.168.16.3 webhost 192.168.16.4
deploy_and_configure server2 webhost 192.168.16.4 loghost 192.168.16.3

# Update local hosts entries
./configure-host_v1.sh $VERBOSE_MODE -he loghost 192.168.16.3
./configure-host_v1.sh $VERBOSE_MODE -he webhost 192.168.16.4
