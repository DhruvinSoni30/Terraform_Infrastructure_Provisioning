# Variables
$cmd_hf = "/usr/bin/"

# Apply the below manifest only on Heavy Forwarder
if $facts['role'] == 'HF' {

# Execute 'apt-get update'
exec { 'Updating packages for Heavy Forwarder':                    
  command => "${cmd_hf}apt-get update"  
}
}
