# Fetching various details from facter
$deployer_ip_idx = $::deployer_ip
$role_idx = $::role
$instance_id_idx = $::instance_id
$cmd_idx = "/usr/bin/"
$splunk_dir_idx = "/opt/splunk"
$region_idx = $::region

# Apply this manifest only on indexer
if $facts['role'] == "idx" {

# Fetching splunk password
$splunk_password_idx = inline_template('<%= `/usr/bin/aws secretsmanager get-secret-value --region us-east-2 --secret-id Splunk_Password | jq -r .SecretString`.chomp %>')

# Executing 'apt-get update'
exec { 'Updating the packages for indexer':                    
  command => "${cmd_idx}apt-get update"  
}

# Starting Splunk Service
exec { 'Configuring the indexer':
  user => 'root',
  command => "${splunk_dir_idx}/bin/splunk edit cluster-config -mode slave -master_uri https://${deployer_ip_idx}:8089 -replication_port 9887 -secret ${splunk_password_idx} -auth admin:${splunk_password_idx}"
}

# Restarting Splunk Service
exec { 'Restarting splunk service after configurating indexer':
  require => Exec['Configuring the indexer'],
  user => 'root',
  command => "${cmd_idx}systemctl restart splunk"
}

# Setting Splunk hostname
exec { 'Updating servername for indexer':
  user => 'root',
  command =>  "${splunk_dir_idx}/bin/splunk set servername ${role_idx}-${instance_id_idx} -auth admin:${splunk_password_idx}"
}

# Restarting Splunk Service
exec { 'Restarting splunk service after changing servername for searchhead':
  require => Exec['Configuring the indexer'],
  user => 'root',
  command => "${cmd_idx}systemctl restart splunk"
}

# Changing server role to indexer
$lines_to_add_for_idx = [
"[distributedSearch:dmc_group_search_head]

[distributedSearch:dmc_group_cluster_master]

[distributedSearch:dmc_group_license_master]

[distributedSearch:dmc_group_indexer]
default = false
servers = localhost:localhost

[distributedSearch:dmc_group_deployment_server]

[distributedSearch:dmc_group_kv_store]

[distributedSearch:dmc_group_shc_deployer]"

]

$file_location_idx = "${splunk_dir_idx}/etc/system/local/distsearch.conf"

file { $file_location_idx:
  ensure => present,
}

$lines_to_add_for_idx.each |$line| {
  exec { "add_line_${line}":
    command => "${cmd_idx}echo '${line}' >> ${file_location_idx}",
    unless  => "${cmd_idx}grep -Fxq '${line}' ${file_location_idx}",
    require => File[$file_location_idx],
  }
}
}
