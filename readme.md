# OpenVpn Site-to-Site

## Server

### Setup

* Launch new instance of Ubuntu 16.04 LTS inside the desired vpc
* Ssh into the instance
* Execute following commands from a terminal window:
```
git clone https://github.com/vkhazin/openvpn-site2site.git --depth=1 &&
cd ./openvpn-site2site &&
chmod +x ./server/setup.sh &&
./server/setup.sh
```

## Remove all

* Run a terminal window:
```
chmod +x ./server/cleanup.sh &&
./server/cleanup.sh
```