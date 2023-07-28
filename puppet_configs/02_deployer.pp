# Fetching various details from facter
$role_dp = $::role
$instance_id_dp = $::instance_id
$cmd_dp = "/usr/bin/"
$splunk_dir_dp = "/opt/splunk"
$region_dp = $::region

# Apply this manifest only on deployer
if $facts['role'] == "DP" {

# Fetching the Splunk password
$splunk_password_dp = inline_template('<%= `/usr/bin/aws secretsmanager get-secret-value --region us-east-2 --secret-id Splunk_Password | jq -r .SecretString`.chomp %>')

# Executing 'apt-get update'
exec { 'Updating the packages for deployer':                    
  command => "${cmd_dp}apt-get update"  
}

# Starting Splunk Service
exec { 'Configuring the deployer':
  user => 'root',
  command => "${splunk_dir_dp}/bin/splunk edit cluster-config -mode master -replication_factor 3 -search_factor 2 -secret ${splunk_password_dp} -auth admin:${splunk_password_dp}"
}

# Restarting Splunk Service
exec { 'Restarting splunk service after configurating deployer':
  require => Exec['Configuring the deployer'],
  user => 'root',
  command => "${cmd_dp}systemctl restart splunk"
}

# Setting Splunk hostname
exec { 'Updating servername for deployer':
  user => 'root',
  command =>  "${splunk_dir_dp}/bin/splunk set servername ${role_dp}-${instance_id_dp} -auth admin:${splunk_password_dp}"
}

# Restarting Splunk Service
exec { 'Restarting splunk service after changing servername for deployer':
  require => Exec['Configuring the deployer'],
  user => 'root',
  command => "${cmd_dp}systemctl restart splunk"
}

# Changing server role to deployer, cluster master & license master
$lines_to_add_for_dp = [
"[distributedSearch:dmc_group_search_head]

[distributedSearch:dmc_group_cluster_master]
servers = localhost:localhost

[distributedSearch:dmc_group_license_master]
servers = localhost:localhost

[distributedSearch:dmc_group_indexer]
default = false

[distributedSearch:dmc_group_deployment_server]
servers = localhost:localhost

[distributedSearch:dmc_group_kv_store]

[distributedSearch:dmc_group_shc_deployer]"

]

$file_location_dp = "${splunk_dir_dp}/etc/system/local/distsearch.conf"

file { $file_location_dp:
  ensure => present,
}

$lines_to_add_for_dp.each |$line| {
  exec { "add_line_${line}":
    command => "${cmd_dp}echo '${line}' >> ${file_location_dp}",
    unless  => "${cmd_dp}grep -Fxq '${line}' ${file_location_dp}",
    require => File[$file_path],
  }
}

# Removing temporary file
exec { 'Removing the tmp file':
  user => 'root',
  command => "${cmd_dp}rm /tmp/tmp.txt"
}
}
