# OpenVpn Site-to-Site (UNFINISHED)

## Server

### Setup

* Launch new instance of Ubuntu 16.04 LTS inside the desired vpc
* Ssh into the instance
* Execute following commands from a terminal window:
```
git clone https://github.com/vkhazin/openvpn-site2site.git --depth=1 &&
cd ./openvpn-site2site &&
chmod +x ./server/setup.sh
```
* Double check settings in `./vars` match your server/client networks
* Run the setup: `./server/setup.sh`
* ./server/client.conf is a file you will need to use connecting to the newly provisioned openvpn server
* To test conectivity from the client: `openvpn --config /path/to/client.conf`

## Remove all

* Run a terminal window:
```
chmod +x ./server/cleanup.sh &&
./server/cleanup.sh
```
* To delete all the files:
```
cd ~/ &&
rm -rf ./openvpn-site2site
```

## Client

### Setup

* Launch new instance of Ubuntu 16.04 LTS inside the desired vpc
* Ssh into the instance
* Execute following commands from a terminal window:
```
git clone https://github.com/vkhazin/openvpn-site2site.git --depth=1 &&
cd ./openvpn-site2site &&
chmod +x ./client/client.sh &&
```
* Copy `./server/client.conf` file from server setup to ./client/client.conf folder on the client
* Run the setup: `./client/setup.sh`
* https://docs.aws.amazon.com/vpc/latest/userguide/VPC_NAT_Instance.html#EIP_Disable_SrcDestCheck
* https://askubuntu.com/questions/948817/ubuntu-16-04-auto-start-vpn

## TODO:

* Server is no NAT it is ROUTE
* Client NAT is missing
* Route tables on the client and the server end are missing
* Security groups rules may be missing too