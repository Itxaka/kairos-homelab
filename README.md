## kairos testlab

This will set up a 3 node k3s cluster, with 1 master and 2 workers automatically with no further configuration by the user


This is set as a example on how to deploy a complex service easily just just a couple of config files


only needed argument is iso_path which is the iso to boot from. You can choose any iso from https://github.com/kairos-io/kairos/releases as long as its a standard versions, which ships k3s in the iso.

a simple `terraform apply` should setup the systems in less than 5 minutes via libvirt

You can override both `firmware` and `nvram_template` for systems that ship both files in different locations (defaults should be good for most distributions)