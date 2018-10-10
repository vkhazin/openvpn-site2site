#####################################################################
# Initialize the variables                                          #
#####################################################################
source ../vars &&
source ./client/vars &&

sudo apt-get update &&
#sudo apt-get install openvpn awscli -y &&

# export instanceId=`curl -s http://169.254.169.254/latest/meta-data/instance-id` &&
# aws ec2 modify-instance-attribute \
#         --instance-id $instanceId \
#         --no-source-dest-check

# aws ec2  
#         modify-instance-attribute \
#         --no-source-dest-check

# Disable source/dest check
# Configure route from-to client/server

# Configure client side routing
sudo sysctl -w net.ipv4.ip_forward=1 &&
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE &&
sudo iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT &&
sudo iptables -A FORWARD -i eth0 -o tun0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT &&
sudo mkdir /etc/iptables &&
sudo bash -c "iptables-save > /etc/iptables/rules.v4" &&
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections &&
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections &&
sudo apt-get install iptables-persistent -y

