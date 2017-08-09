#!/bin/bash
#
# Container Bridge for Making Docker Containers Available on the local Inter/Intranet
# Only for Mac OS X Yosemite or higher
# Created by G. Michael Youngblood at PARC, February 2016
#
# Depends on socat, which can be installed via brew
# $ brew install socat
#
# Get brew from http://brew.sh/
#
CONTAINER_IP=192.168.99.100
BRIDGE_PORTS=(10000 10001 9550 9551 9552 9553 9554 9555 9556 9557 9558 9559)
newline=$'\n'
bridge_rules="${newline}"

echo "Docker Bridger for Mac OS X Yosemite and higher"
echo "-----------------------------------------------"
echo "If asked for password, it is for sudo access to install the temporary firewall rules"

# Clear all running socat bridges
killall socat

# Remove all port forwarding
sudo pfctl -F all -f /etc/pf.conf

# Setup bridges and routes
for port in "${BRIDGE_PORTS[@]}"
do 
  echo "Bridging port $port from $CONTAINER_IP"
  # Bridge tool from container to localhost
  socat tcp4-listen:$port,fork tcp4:$CONTAINER_IP:$port &
  # Firewall rule setup to route net traffic to localhost
  bridge_rules+="${newline}rdr pass inet proto tcp from any to any port {$port} -> 127.0.0.1 port $port"
done

# Install rules
echo "Installing..."
echo "$bridge_rules"
echo "$bridge_rules" | sudo pfctl -Ef -
echo "PF says..."
sudo pfctl -s nat