#####################################################################
# Set up variables                                                  #
#####################################################################
source ../vars
export sourceFolder=`pwd`/server &&
export easyRsaFolder='/usr/share/easy-rsa' &&
export openVpnConfigFolder='/etc/openvpn' &&
#####################################################################

#####################################################################
# Install pre-requisies                                             #
#####################################################################
sudo apt-get update &&
sudo apt-get install openvpn easy-rsa -y &&
#####################################################################

#####################################################################
# Copy vars and server.conf                                         #
#####################################################################
sudo mkdir $openVpnConfigFolder/keys &&
sudo cp $sourceFolder/vars $openVpnConfigFolder/vars &&
sudo cp $sourceFolder/dh2048.pem $openVpnConfigFolder/keys &&
#####################################################################

#####################################################################
# Configure server.conf                                             #
#####################################################################
# common settings
echo -e "\n" | sudo tee --append $sourceFolder/server.conf &&
echo "server $vpn_nw_subnet $vpn_nw_mask" | sudo tee --append $sourceFolder/server.conf &&
echo "route $client_nw_subnet $client_nw_mask" | sudo tee --append $sourceFolder/server.conf &&
echo "push \"route $client_nw_subnet $client_nw_mask\"" | sudo tee --append $sourceFolder/server.conf &&
echo "push \"route $server_nw_subnet $server_nw_mask\"" | sudo tee --append $sourceFolder/server.conf &&
# tcp
sudo cp $sourceFolder/server.conf $openVpnConfigFolder/server-tcp-443.conf &&
echo "port 443" | sudo tee --append $openVpnConfigFolder/server-tcp-443.conf &&
echo "proto tcp-server" | sudo tee --append $openVpnConfigFolder/server-tcp-443.conf &&
sudo cp $sourceFolder/server.conf $openVpnConfigFolder/server-udp-1194.conf &&
# udp
echo "port 1194" | sudo tee --append $openVpnConfigFolder/server-udp-1194.conf &&
echo "proto udp" | sudo tee --append $openVpnConfigFolder/server-udp-1194.conf &&
#####################################################################

#####################################################################
# Generate Keys                                                     #
#####################################################################
export clientId=client &&
source $openVpnConfigFolder/vars &&
sudo -E $easyRsaFolder/clean-all &&
sudo -E $easyRsaFolder/build-ca --batch &&
sudo -E $easyRsaFolder/build-key-server --batch server &&
sudo -E openvpn --genkey --secret $openVpnConfigFolder/keys/ta.key &&
sudo -E $easyRsaFolder/build-key --batch $clientId &&
#openssl dhparam -out ./keys/dh2048.pem 2048 # Takes too long
#####################################################################

#####################################################################
# Copy keys to $openVpnConfigFolder/keys                            #
#####################################################################
sudo cp $sourceFolder/dh2048.pem $openVpnConfigFolder/keys &&
sudo cp -r $easyRsaFolder/keys $openVpnConfigFolder &&
#####################################################################

#####################################################################
# Start Service                                                     #
#####################################################################
sudo service openvpn start &&
#####################################################################

#####################################################################
# Configure Forwarding and Nat                                      #
#####################################################################
sudo sysctl -w net.ipv4.ip_forward=1 &&
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE &&
sudo iptables -A FORWARD -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT &&
sudo iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT &&
sudo mkdir /etc/iptables &&
sudo bash -c "iptables-save > /etc/iptables/rules.v4" &&
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections &&
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections &&
sudo apt-get install iptables-persistent -y &&
#####################################################################

#####################################################################
# Prepare client.conf                                               #
#####################################################################
export serverId=`curl -s ipinfo.io/ip` &&
echo "remote" $serverId "1194 udp" | sudo tee --append $sourceFolder/client.conf &&
echo "remote" $serverId "443 tcp" | sudo tee --append $sourceFolder/client.conf &&
echo "<ca>" | sudo tee --append $sourceFolder/client.conf &&
sudo cat $openVpnConfigFolder/keys/ca.crt | sudo tee --append $sourceFolder/client.conf &&
echo "</ca>" | sudo tee --append $sourceFolder/client.conf &&
echo "<cert>" | sudo tee --append $sourceFolder/client.conf &&
sudo cat $openVpnConfigFolder/keys/client.crt | sudo tee --append $sourceFolder/client.conf &&
echo "</cert>" | sudo tee --append $sourceFolder/client.conf &&
echo "<key>" | sudo tee --append $sourceFolder/client.conf &&
sudo cat $openVpnConfigFolder/keys/client.key | sudo tee --append $sourceFolder/client.conf &&
echo "</key>" | sudo tee --append $sourceFolder/client.conf &&
echo "key-direction 1" | sudo tee --append $sourceFolder/client.conf &&
echo "<tls-auth>" | sudo tee --append $sourceFolder/client.conf &&
sudo cat $openVpnConfigFolder/keys/ta.key | sudo tee --append $sourceFolder/client.conf &&
echo "</tls-auth>" | sudo tee --append $sourceFolder/client.conf &&
#####################################################################

#####################################################################
# Restart the service                                               #
#####################################################################
sudo service openvpn restart
#####################################################################