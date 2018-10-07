#####################################################################
# Initialize the variables                                          #
#####################################################################
source ../vars &&
source ./client/vars &&

sudo apt-get update &&
sudo apt-get install openvpn awscli -y &&


# export instanceId=`curl -s http://169.254.169.254/latest/meta-data/instance-id` &&
# aws ec2 modify-instance-attribute \
#         --instance-id $instanceId \
#         --no-source-dest-check

# aws ec2  
#         modify-instance-attribute \
#         --no-source-dest-check

# Disable source/dest check
# Configure route from-to client/server