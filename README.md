# Puppet configuration file

* These are the puppet configuration files for installing splunk and configuring the Deployer, Search Head & Indexer.

* In order to setup the cluster we need run below command on the agent nodes: 

    ```puppet agent -t```
  
* However, puppet agent will autoatically run every 15 minutes on the agent nodes and pull the latest catalog from master node.

![puppet.png](https://github.com/DhruvinSoni30/Splunk_Infrastructure/blob/main/images/puppet.png)
