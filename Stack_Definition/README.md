# Stack related files go here

* Whenever any new customer wants to use our application we need to set up the infrastructure for them and follow the below steps.
  1. Create a folder as per the name of stack
  2. Create `terraform.tfvars` file in it with the required set of parameters.
  3. Commit the changes. That's it the rest of the work will be done by automation.

  Ex. of `terraform.tfvars` file:
  ```
  # Stack name
  project_name = "<stack-name>"

  # Indexer's instance type
  idx_instance_type = "<indexer's instance size>"

  # SH instance type
  sh_instance_type = "<SH's instance size>"

  # HF instance type
  hf_instance_type = "<HF's instance size>"

  # DP instance type
  dp_instance_type = "<DP's instance size>"

  # Master instance type
  master_instance_type = "<Master's instance size>"

  # Region
  region = "<Region>"

  # UI Access
  ui_access = <List of IPs>

  # HEC Access
  hec_access = <List of IPs>

  # SSH Access
  ssh_access = <List of IPs>

  # Ingest Access
  ingest_access = <List of IPs>
  ```
     
