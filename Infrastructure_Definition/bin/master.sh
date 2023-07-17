#!/bin/bash

# Creating Hostname
hostname="puppetmaster.test.org"
echo "$hostname" >> $logfile

# Setting Hostname 
sudo hostname "$hostname"

# Creating DNS and adding in hosts file
echo "$private_ip $hostname" | tee --append /etc/hosts

# Installing Dependencies 
ebs_device="/dev/xvdf"
sudo apt-get install wget curl unzip software-properties-common gnupg2 -y
sudo curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update -y
sudo apt-get install terraform -y
sudo apt-get install xfsprogs -y
sudo apt-get install jq -y
sudo apt install awscli -y
sudo apt-get update -y
sudo wget https://apt.puppetlabs.com/puppet6-release-focal.deb
sudo dpkg -i puppet6-release-focal.deb
sudo apt-get update -y
sleep 5
sudo apt-get install puppetserver -y
sudo systemctl start puppetserver
sudo systemctl enable puppetserver
sudo mkfs -t ext4 $ebs_device
splunkdir=/opt/splunk
logfile=/tmp/logs.txt
sudo touch $logfile

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

# Getting Instance details
identity_doc=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document/)
availability_zone=$(echo "$identity_doc" | jq -r '.availabilityZone')
instance_id=$(echo "$identity_doc" | jq -r '.instanceId')
private_ip=$(echo "$identity_doc" | jq -r '.privateIp')
public_ip=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
account_id=$(echo "$identity_doc" | jq -r '.accountId')
region=$(echo "$identity_doc" | jq -r '.region')
ebs_tag_key="Snapshot"
ebs_tag_value="true"

# Fetching Instance IDs of all the agent nodes & appending it to /etc/hosts file 
agents=$(aws ec2 describe-instances --region "$region" --filters "Name=tag:PuppetEnv,Values=production" --query 'Reservations[].Instances[?State.Name==`running` || State.Name==`pending`].[PrivateIpAddress, InstanceId]' --output text)
echo $agents | tee --append /etc/hosts

# Updating puppet.conf file
cat > /etc/puppetlabs/puppet/puppet.conf << EOF
[main]
certname = $hostname
server = $hostname
environment = production
runinterval = 15m
EOF

# Restarting Puppetserver
sudo systemctl restart puppetserver

# Getting tags from EC2 instance
tags=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" --region="$region" | jq '.Tags[]')
echo "$tags" >> $logfile

# Getting the value of tag role
role=$(echo "$tags" | jq -r 'select(.Key == "role") .Value')
echo "$role" >> $logfile

# Create facts.d directory
facter_dir=/etc/puppetlabs/facter
facts_d_dir=${facter_dir}/facts.d
sudo mkdir -p $facts_d_dir

# These facts are needed for Puppet to know which Parameter to target
cat > $facts_d_dir/instance_facts.yaml << YAML
---
instance_id: $instance_id
rgion: $region
role: $role
ec2_availability_zone: $availability_zone
zone: $availability_zone
YAML

# Creating Name tag
value="${role//_/-}-${instance_id}"

# Creating tag and attach it to EC2 instance
aws ec2 create-tags --resources "$instance_id" --region="$region" --tags "Key=Name,Value=$value"

# Checking whether tag is attached or not
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

# Wait till the volume gets attached
state=$(aws ec2 describe-volumes --region "$region" --volume-ids "$attached_volume" | jq -r '.Volumes[].Attachments[].State')	
if [ "$state" == "attached" ]; then	
    echo "Volume attached success"  >> $logfile	
fi	
sleep 5	

# Checking whether the volume is already mounted or not if not the mounting it 
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

# Retrieving EIPs that are not associate with any Instance
eips=$(aws ec2 describe-addresses --query "Addresses[?NetworkInterfaceId == null ].PublicIp" --region="$region" --output text)

# Attaching EIP to Instance
aws ec2 associate-address --region "$region" --public-ip "$eips" --instance-id "$instance_id"

# Fetching the count of all the agent nodes
agent_count=$(aws ec2 describe-instances --region "$region" --filters "Name=tag:PuppetEnv,Values=production" "Name=instance-state-name,Values=running,pending" --query 'length(Reservations[].Instances[])')
master_count=1

final_count=$(($agent_count+$master_count))
echo $final_count >> $logfile

cert_count=$(sudo /opt/puppetlabs/bin/puppetserver ca list --all | grep -i SHA256 | wc -l)
echo $cert_count >> $logfile

# Checking whether the configuration of all the agents has done or not 
while [ "$final_count" != "$cert_count" ]; do 
    sleep 5
    cert_count=$(sudo /opt/puppetlabs/bin/puppetserver ca list --all | grep -i SHA256 | wc -l)
done

# Signing all the certs 
sudo /opt/puppetlabs/bin/puppetserver ca sign --all
puppet_exitcode=$?
if [ "$puppet_exitcode" != "0" ]; then
    echo "Cert Signed failed" >> $logfile
    echo $puppet_exitcode >> $logfile
fi

# Retrieving puppet code from S3 bucket 
aws s3 cp s3://puppet-code/ /etc/puppetlabs/code/environments/production/manifests/  --recursive