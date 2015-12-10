#!/bin/bash
# set -x
# Adapted from https://puppetlabs.com/blog/bootstrap-rackspace-cloud-servers-puppet-and-libcloud
# and https://www.digitalocean.com/community/tutorials/how-to-install-puppet-in-standalone-mode-on-centos-7

# First, upgrade packages
yum -y update

# Second, install PuppetLabs repository
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm

# Third, install Puppet
yes | yum -y install puppet


