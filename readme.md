# OpenVpn Site-to-Site

## Server Setup

* Launch new instance of Ubuntu 16.04 LTS inside the desired vpc
* Ssh into the instance
* Execute following commands from a terminal window:
```
git clone https://github.com/vkhazin/openvpn-site2site.git \
  && cd ./openvpn-site2site \
  && chmod +x ./server/setup.sh \
  && ./server/setup.sh
  # && echo -e "\nPlease note the public server ip for the client setup: \e[1;32m`curl -s ipinfo.io/ip`\e[0m \n"
```