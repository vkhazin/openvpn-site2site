#####################################################################
# Set up variables                                                     #
#####################################################################
export startFolder=`pwd`
export easyRsaFolder='/usr/share/easy-rsa'
#####################################################################

#####################################################################
# Install pre-requisies                                             #
#####################################################################
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections \
  && echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections \
  && sudo apt-get update \
  && sudo apt-get iptables-persistent openvpn easy-rsa -y
#####################################################################

#####################################################################
# Copy vars and server.conf                                         #
#####################################################################
sudo mkdir /etc/openvpn \
  && sudo mkdir /etc/openvpn/keys \
  && sudo cp ./vars /etc/openvpn/vars \
  && sudo cp ./dh2048.pem /etc/openvpn/keys
#####################################################################

#####################################################################
# Configure server.conf                                             #
#####################################################################
sudo cp ./server.conf /etc/openvpn/server-tcp-443.conf \
  && echo "port 443" | sudo tee --append /etc/openvpn/server-tcp-443.conf \
  && echo "proto tcp-server" | sudo tee --append /etc/openvpn/server-tcp-443.conf \
  && echo "server 172.16.255.0 255.255.255.0" | sudo tee --append /etc/openvpn/server-tcp-443.conf

sudo cp ./server.conf /etc/openvpn/server-udp-1194.conf \
  && echo "port 1194" | sudo tee --append /etc/openvpn/server-udp-1194.conf \
  && echo "proto udp" | sudo tee --append /etc/openvpn/server-udp-1194.conf \
  && echo "server 172.16.254.0 255.255.255.0" | sudo tee --append /etc/openvpn/server-udp-1194.conf
#####################################################################

#####################################################################
# Generate Server keys                                              #
#####################################################################
source /etc/openvpn/vars \
  && sudo -E $easyRsaFolder/clean-all \
  && sudo -E $easyRsaFolder/build-ca --batch \
  && sudo -E $easyRsaFolder/build-key-server --batch server \
  && sudo -E openvpn --genkey --secret /etc/openvpn/keys/ta.key
#openssl dhparam -out ./keys/dh2048.pem 2048 # Takes too long
#####################################################################

#####################################################################
# Generate Client keys                                              #
#####################################################################
expost clientId=client \
  && sudo -E $easyRsaFolder/build-key --batch $clientId
#####################################################################

#####################################################################
# Copy keys to /etc/openvpn/keys                                    #
#####################################################################
sudo cp $startFolder/dh2048.pem /etc/openvpn/keys \
  && sudo cp -r $easyRsaFolder/keys/* /etc/openvpn/keys
#####################################################################

#####################################################################
# Start Service                                                     #
#####################################################################
sudo service openvpn start
#####################################################################

#####################################################################
# Configure Forwarding and Nat                                      #
#####################################################################
sudo sysctl -w net.ipv4.ip_forward=1 \
  && sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE \
  && sudo iptables -A FORWARD -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT \
  && sudo iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT \
  && sudo bash -c "iptables-save > /etc/iptables/rules.v4" \
  && sudo -E service iptables-persistent start
#####################################################################

#####################################################################
# Copy client keys to home directory                                #
#####################################################################
mkdir ./client \
  && sudo cp /etc/openvpn/keys/$clientId.crt ./client \
  && sudo cp /etc/openvpn/keys/$clientId.key ./client \
  && sudo cp /etc/openvpn/keys/ca.crt ./client \
  && cp /etc/openvpn/keys/ta.key ./client

#####################################################################
# Configure client.conf                                             #
#####################################################################
export serverId=`curl -s ipinfo.io/ip`
sudo cp ./client.conf ./client/client.conf
# Append server ip
echo "remote" $serverId "1194 udp" | sudo tee --append ./client/client.conf
echo "remote" $serverId "443 tcp" | sudo tee --append ./client/client.conf
# Append ca
echo "<ca>" | sudo tee --append ./client/client.conf
sudo cat ./client/ca.crt | sudo tee --append ./client/client.conf
echo "</ca>" | sudo tee --append ./client/client.conf
# Append client cert
echo "<cert>" | sudo tee --append ./client/client.conf
sudo cat ./client/client.crt | sudo tee --append ./client/client.conf
echo "</cert>" | sudo tee --append ./client/client.conf
# Append client key
echo "<key>" | sudo tee --append ./client/client.conf
sudo cat ./client/client.key | sudo tee --append ./client/client.conf
echo "</key>" | sudo tee --append ./client/client.conf
# Append ta
echo "key-direction 1" | sudo tee --append ./client/client.conf
echo "<tls-auth>" | sudo tee --append ./client/client.conf
sudo cat ./client/ta.key | sudo tee --append ./client/client.conf
echo "</tls-auth>" | sudo tee --append ./client/client.conf