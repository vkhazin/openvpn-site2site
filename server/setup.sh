#####################################################################
# Initialize the variables                                          #
#####################################################################
source ./vars
source ./server/vars
#####################################################################

#####################################################################
# Copy vars and server.conf                                         #
#####################################################################
sudo mkdir /etc/openvpn \
  && sudo mkdir /etc/openvpn/keys \
  && sudo cp ./server/vars /etc/openvpn/vars \
  && sudo cp ./server/keys/* /etc/openvpn/keys
#####################################################################

#####################################################################
# Configure server.conf                                             #
#####################################################################
sudo cp ./server/server.conf /etc/openvpn/server-tcp-443.conf \
  && echo "port 443" | sudo tee --append /etc/openvpn/server-tcp-443.conf \
  && echo "proto tcp-server" | sudo tee --append /etc/openvpn/server-tcp-443.conf \
  && echo "server $server_nw_subnet $server_nw_mask" | sudo tee --append /etc/openvpn/server-tcp-443.conf \
  && sudo cp ./server/server.conf /etc/openvpn/server-udp-1194.conf \
  && echo "port 1194" | sudo tee --append /etc/openvpn/server-udp-1194.conf \
  && echo "proto udp" | sudo tee --append /etc/openvpn/server-udp-1194.conf \
  && echo "server $server_nw_subnet $server_nw_mask" | sudo tee --append /etc/openvpn/server-udp-1194.conf
#####################################################################

#####################################################################
# Install OpenVpn using epel repositories                           #
#####################################################################
sudo amazon-linux-extras install epel -y \
  && sudo yum update -y \
  && sudo yum install openvpn -y
#####################################################################

#####################################################################
# Generate OpenVpn Key                           #
#####################################################################
sudo -E openvpn --genkey --secret /etc/openvpn/keys/ta.key
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