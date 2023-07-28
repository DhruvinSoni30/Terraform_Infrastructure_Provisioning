$splunk_home = "/opt/splunk"
$cmd_dir = "/usr/bin/"
$admin_pwd = inline_template('<%= `/usr/bin/aws secretsmanager get-secret-value --region us-east-2 --secret-id Splunk_Password | jq -r .SecretString`.chomp %>')

# Executing'apt-get update'
exec { 'Updating the package':   
  user => 'root',               
  command => "${cmd_dir}apt-get update"
}

# Downloading  Splunk tar file
file { '/tmp/splunk-9.0.4.1-419ad9369127-Linux-x86_64.tgz':
  ensure => present,
  source => 'https://download.splunk.com/products/splunk/releases/9.0.4.1/linux/splunk-9.0.4.1-419ad9369127-Linux-x86_64.tgz',
}

# Extracting Splunk package
exec { 'Extracting the splunk package':
  user => 'root',
  command => "${cmd_dir}tar -xzf /tmp/splunk-9.0.4.1-419ad9369127-Linux-x86_64.tgz -C /opt/splunk"
}

# Removing Splunk package
exec { 'Removing the splunk package':
  require => Exec['Extracting the splunk package'], 
  user => 'root',     
  command => "${cmd_dir}rm -rf /tmp/splunk-9.0.4.1-419ad9369127-Linux-x86_64.tgz"
}

# Copying files to /opt/splunk
exec { 'Removing the unnecessary files':
  require => Exec['Removing the splunk package'], 
  cwd => '/opt/splunk/splunk',
  user => 'root',
  command => "${cmd_dir}mv * ../ & cd .. & rm -rf splunk/"
}

# Starting Splunk Service for the first time
exec { 'Starting the splunk service for first time':
  require => Exec['Removing the unnecessary files'],
  user => 'root',
  command => "${splunk_home}/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd ${$admin_pwd}",
  onlyif   => "${cmd_dir}test -f /tmp/tmp.txt"
}

# Stopping Splunk Service
exec { 'Stoping the splunk service':
  require => Exec['Starting the splunk service for first time'],
  user => 'root',
  command => "${splunk_home}/bin/splunk stop",
  onlyif   => "${cmd_dir}test -f /tmp/tmp.txt"
}

# Configuring Splunk service to manage it with systemctl
$lines_to_add = [
"[Unit]
Description=Splunk
After=network.target

[Service]
ExecStart=/opt/splunk/bin/splunk start
Type=forking
User=root
Group=root
Restart=on-failure
TimeoutSec=300

[Install]
WantedBy=multi-user.target"
]

$file_path = '/etc/systemd/system/splunk.service'

file { $file_path:
  ensure => present,
}

$lines_to_add.each |$line| {
  exec { "add_line_${line}":
    command => "${cmd_dir}echo '${line}' >> ${file_path}",
    unless  => "${cmd_dir}grep -Fxq '${line}' ${file_path}",
    require => File[$file_path],
  }
}

# Reloading Daemon
exec { 'Reloading the daemon':
  user => 'root',
  command => "${cmd_dir}systemctl daemon-reload",
  onlyif   => "${cmd_dir}test -f /tmp/tmp.txt"
}

# Enabling Splunk service
exec { 'Enabling the splunk service':
  user => 'root',
  command => "${cmd_dir}systemctl enable splunk",
  onlyif   => "${cmd_dir}test -f /tmp/tmp.txt"
}

# Starting Splunk service
exec { 'Restarting the splunk service via systemctl':
  user => 'root',
  command => "${cmd_dir}systemctl start splunk",
  onlyif   => "${cmd_dir}test -f /tmp/tmp.txt"
}
