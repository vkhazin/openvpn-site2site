sudo rm -rf /usr/share/easy-rsa/keys &&
sudo apt-get remove iptables-persistent openvpn easy-rsa -y &&
sudo apt autoremove -y &&
sudo rm -rf /etc/openvpn