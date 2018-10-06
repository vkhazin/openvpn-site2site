#####################################################################
# Initialize the variables                                          #
#####################################################################
source ./vars
source ./client/vars

#####################################################################
# Set server ip                                                     #
#####################################################################
echo "remote" $serverId "1194 udp" | sudo tee --append ./client/client.conf
echo "remote" $serverId "443 tcp" | sudo tee --append ./client/client.conf

#####################################################################

#####################################################################
# Copy vars and client.conf                                         #
#####################################################################
sudo mkdir /etc/openvpn \
  && sudo mkdir /etc/openvpn/keys \
  && sudo cp ./client/keys/* /etc/openvpn/keys \
  && sudo cp ./client/client.conf /etc/openvpn/client.conf
#####################################################################

#####################################################################
# Start OpenVpn Service                                             #
#####################################################################
sudo service openvpn start
#####################################################################

#####################################################################
# Configure Forwarding and Nat                                      #
#####################################################################
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
sudo service iptables save
#####################################################################