#!/bin/bash
# set -x
# Adapted from https://puppetlabs.com/blog/bootstrap-rackspace-cloud-servers-puppet-and-libcloud
# and https://www.digitalocean.com/community/tutorials/how-to-install-puppet-in-standalone-mode-on-centos-7

# Check for required tool
LSB=lsb_release
type -P "${LSB}" > /dev/null && echo "${LSB} found, continuing..." || { echo "${LSB} not found, install first! Now exiting..."; exit 1; }

# Determine distro
DISTRO=$(lsb_release -si)

case ${DISTRO} in
    CentOS)
        echo "CentOS detected"
        ;;
    Ubuntu)
        echo "Ubuntu detected"
        ;;
    *)
        echo "Unsupported distribution. Sorry..."
        exit 2
esac

# First, upgrade packages
yum -y update

# Second, install PuppetLabs repository
rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm

# Third, install Puppet
yes | yum -y install puppet


