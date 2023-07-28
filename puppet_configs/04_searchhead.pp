# Fetching various details from facter
$deployer_ip_sh = $::deployer_ip
$role_sh = $::role
$instance_id_sh = $::instance_id
$cmd_sh = "/usr/bin/"
$splunk_dir_sh = "/opt/splunk"
$region_sh = $::region

# Apply the below manifest only on Search Head
if $facts['role'] == "SH" {

# Fetching splunk password
$splunk_password_sh = inline_template('<%= `/usr/bin/aws secretsmanager get-secret-value --region us-east-2 --secret-id Splunk_Password | jq -r .SecretString`.chomp %>')

# Executing 'apt-get update'
exec { 'Updating the packages for Search Head':                    
  command => "${cmd_sh}apt-get update"  
}

# Starting Splunk Service
exec { 'Configuring the Search Head':
  user => 'root',
  command => "${splunk_dir_sh}/bin/splunk edit cluster-config -mode searchhead -master_uri https://${deployer_ip_sh}:8089 -secret ${splunk_password_sh} -auth admin:${splunk_password_sh}"
}

# Restarting Splunk Service
exec { 'Restarting splunk service after configurating sarchhead':
  require => Exec['Configuring the Search Head'],
  user => 'root',
  command => "${cmd_sh}systemctl restart splunk"
}

# Setting Splunk hostname
exec { 'Updating servername for Search Head':
  user => 'root',
  command =>  "${splunk_dir_sh}/bin/splunk set servername ${role_sh}-${instance_id_sh} -auth admin:${splunk_password_sh}"
}

# Restarting Splunk Service
exec { 'Restarting splunk service after changing servername for Search Head':
  require => Exec['Configuring the Search Head'],
  user => 'root',
  command => "${cmd_sh}systemctl restart splunk"
}

# Changing server role to Search Head
$lines_to_add_for_sh = [
"[distributedSearch:dmc_group_search_head]
servers = localhost:localhost

[distributedSearch:dmc_group_cluster_master]

[distributedSearch:dmc_group_license_master]

[distributedSearch:dmc_group_indexer]
default = false

[distributedSearch:dmc_group_deployment_server]

[distributedSearch:dmc_group_kv_store]

[distributedSearch:dmc_group_shc_deployer]"

]

$file_location_sh = "${splunk_dir_sh}/etc/system/local/distsearch.conf"

file { $file_location_sh:
  ensure => present,
}

$lines_to_add_for_sh.each |$line| {
  exec { "add_line_${line}":
    command => "${cmd_sh}echo '${line}' >> ${file_location_sh}",
    unless  => "${cmd_sh}grep -Fxq '${line}' ${file_location_sh}",
    require => File[$file_location_sh],
  }
}
}
