#!/bin/bash
# configure-host_v1.sh - Configures host settings

handle_signals() {
    trap '' SIGTERM SIGHUP SIGINT
}

handle_signals

VERBOSE=0
HOST_MODIFIED=0
IP_MODIFIED=0

set_hostname() {
    req_name="$1"
    if [ "$(hostname)" != "$req_name" ]; then
        echo "$req_name" > /etc/hostname
        hostnamectl set-hostname "$req_name"
        HOST_MODIFIED=1
        logger "Hostname updated to $req_name"
    fi
    [ $VERBOSE -eq 1 ] && { [ $HOST_MODIFIED -eq 1 ] && echo "Hostname set to $req_name" || echo "Hostname unchanged"; }
}

assign_ip() {
    req_ip="$1"
    iface=$(ip -4 route ls | grep default | grep -Po '(?<=dev )\S+' | head -1)
    if [ -n "$iface" ]; then
        current_ip=$(hostname -I | awk '{print $1}')
        if [ "$current_ip" != "$req_ip" ]; then
            ip addr add "$req_ip/24" dev "$iface"
            IP_MODIFIED=1
            logger "IP modified to $req_ip on $iface"
        fi
    fi
    [ $VERBOSE -eq 1 ] && { [ $IP_MODIFIED -eq 1 ] && echo "IP set to $req_ip" || echo "IP unchanged"; }
}

update_hosts() {
    name="$1"
    ip="$2"
    if ! grep -qs "$ip $name" /etc/hosts; then
        echo "$ip $name" >> /etc/hosts
        logger "Hosts file updated: $name $ip"
    fi
    [ $VERBOSE -eq 1 ] && echo "Hosts file processed for $name $ip"
}

while [ "$#" -gt 0 ]; do
    case $1 in
        -verbose) VERBOSE=1 ;;
        -n) set_hostname "$2"; shift ;;
        -i) assign_ip "$2"; shift ;;
        -he) update_hosts "$2" "$3"; shift 2 ;;
    esac
    shift
done
