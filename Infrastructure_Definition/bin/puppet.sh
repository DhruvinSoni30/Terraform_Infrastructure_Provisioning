#!/bin/bash
# Installing Dependencies 
ebs_device="/dev/xvdf"
sudo apt-get update -y
sudo wget https://apt.puppetlabs.com/puppet6-release-focal.deb
sudo dpkg -i puppet6-release-focal.deb
sudo apt-get update -y
sudo apt-get install puppet-agent -y
sudo systemctl start puppet
sudo systemctl enable puppet
sudo apt-get install xfsprogs -y
sudo apt-get install jq -y
sudo apt install awscli -y
sudo apt-get update -y
wget https://apt.puppetlabs.com/puppet6-release-focal.deb
sudo dpkg -i puppet6-release-focal.deb
sudo apt-get update -y
sleep 5
sudo apt-get install puppet-agent -y
sudo systemctl start puppet
sudo systemctl enable puppet
sudo mkfs -t ext4 $ebs_device
splunkdir=/opt/splunk
logfile=/tmp/logs.txt
tmpfile=/tmp/tmp.txt
sudo touch $logfile
sudo touch $tmpfile

# Checking whether splunk home directory exists or not if not then creating it 
if [ -d $splunkdir ]; then
    echo "$splunkdir" exists
else
    sudo mkdir $splunkdir
    echo "dir created" >> $logfile
fi

sleep 10

# Mounting EBS volume to splunk home directory
sudo mount $ebs_device $splunkdir
mount_exitcode=$?
    if [ "$mount_exitcode" != "0" ]; then
        echo "Mount failed" >> $logfile
        echo $mount_exitcode >> $logfile
    fi

# Getting the Instance details
identity_doc=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document/)
availability_zone=$(echo "$identity_doc" | jq -r '.availabilityZone')
instance_id=$(echo "$identity_doc" | jq -r '.instanceId')
private_ip=$(echo "$identity_doc" | jq -r '.privateIp')
public_ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
account_id=$(echo "$identity_doc" | jq -r '.accountId')
region=$(echo "$identity_doc" | jq -r '.region')
ebs_tag_key="Snapshot"
ebs_tag_value="true"

# Getting tags from EC2 instance
tags=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" --region="$region" | jq '.Tags[]')
echo "$tags" >> $logfile

# Getting the value of tag role & puppet_env
role=$(echo "$tags" | jq -r 'select(.Key == "role") .Value')
puppet_env=$(echo "$tags" | jq -r 'select(.Key == "PuppetEnv") .Value')
echo "$role" >> $logfile
echo "$puppet_env" >> $logfile

# Creating the hostname
hostname="${role//_/-}-${instance_id}"
echo "$hostname" >> $logfile

# Setting the hostname 
sudo hostname "$instance_id"

# Creating DNS and adding in hosts file
echo "$private_ip $instance_id" | tee --append /etc/hosts

# Master hostname 
master_hostname="puppetmaster.test.org"

# Fetching instance ID of master node & appending it to /etc/hosts file
master=$(aws ec2 describe-instances --region "$region" --filters "Name=tag:role,Values=Master" --query 'Reservations[].Instances[?State.Name==`running` || State.Name==`pending`].[PrivateIpAddress]' --output text)
echo $master $master_hostname | tee --append /etc/hosts

# Fetching Deployer node's IP
deployer_ip=$(aws ec2 describe-instances --region "$region" --filters "Name=tag:role,Values=DP" --query 'Reservations[].Instances[?State.Name==`running` || State.Name==`pending`].[PrivateIpAddress]' --output text)

# Updating puppet.conf file
cat > /etc/puppetlabs/puppet/puppet.conf << EOF
[main]
certname = $instance_id
server = puppetmaster.test.org
environment = $puppet_env
runinterval = 15m
EOF

# Restarting the Puppet serice
sudo systemctl restart puppet

# Create facts.d directory
facter_dir=/etc/puppetlabs/facter
facts_d_dir=${facter_dir}/facts.d
sudo mkdir -p $facts_d_dir

# These facts are needed for Puppet to know which Parameter to target
cat > $facts_d_dir/instance_facts.yaml << YAML
---
instance_id: $instance_id
region: $region
role: $role
ec2_availability_zone: $availability_zone
zone: $availability_zone
deployer_ip: $deployer_ip
YAML

# Creating Name tag and attach it to EC2 instance
aws ec2 create-tags --resources "$instance_id" --region="$region" --tags "Key=Name,Value=$hostname"

if [ $? -eq 0 ]; then
    echo "Tag attached" >> $logfile
fi

# Retrieving the volume ids whose state is available
volume_ids=$(aws ec2 describe-volumes --region "$region" --filters Name=tag:"$ebs_tag_key",Values="$ebs_tag_value" Name=availability-zone,Values="$availability_zone" Name=status,Values=available | jq -r '.Volumes[].VolumeId')	
echo "$volume_ids"  >> $logfile	    	
if [ -n "$volume_ids" ]; then	
    break	
fi	

# Attaching the volume to the Instance (The volume will remain the same after instance gets reprovision)
for volume_id in $volume_ids; do
    aws ec2 attach-volume --region "$region" --volume-id "$volume_id" --instance-id "$instance_id" --device "$ebs_device"

    # Checking whether volume attached or not
    if [ $? -eq 0 ]; then
        echo "Volume attached" >> $logfile
        attached_volume=$volume_id
    fi
done

# Wait till volume gets attached
state=$(aws ec2 describe-volumes --region "$region" --volume-ids "$attached_volume" | jq -r '.Volumes[].Attachments[].State')	
if [ "$state" == "attached" ]; then	
    echo "Volume attached success"  >> $logfile	
fi	
sleep 5	

# Checking whether volume is already mounted or not if not then mount it
df -h | grep -i /opt/splunk
mount_code=$?

if [ "$mount_code" != "0" ]; then
    # Mounting the EBS volume to splunkdir
    sudo mount $ebs_device $splunkdir   
    mount_exitcode=$?
    if [ "$mount_exitcode" != "0" ]; then
      echo "Mount failed" >> $logfile
      echo $mount_exitcode >> $logfile
    fi
fi

# Retrieve EIPs that are not associate with any Instance
eips=$(aws ec2 describe-addresses --query "Addresses[?NetworkInterfaceId == null ].PublicIp" --region="$region" --output text)

# Attaching EIP 
aws ec2 associate-address --region "$region" --public-ip "$eips" --instance-id "$instance_id"
