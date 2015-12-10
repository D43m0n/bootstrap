#!/bin/bash
# set -x
# Adapted from https://puppetlabs.com/blog/bootstrap-rackspace-cloud-servers-puppet-and-libcloud
# and https://www.digitalocean.com/community/tutorials/how-to-install-puppet-in-standalone-mode-on-centos-7

#### Check for required tool ####
LSB=lsb_release
type -P "${LSB}" > /dev/null && echo "${LSB} found, continuing..." || { echo "${LSB} not found, install first! Now exiting..."; exit 1; }

#### Determine distro ####
DISTRO=$(lsb_release -si)

#### functions ####
function do_centos {
    echo "CentOS version: ${1}"
    
    # First, upgrade packages
    yum -y update

    # Second, install PuppetLabs repository
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-pc1-el-${1}.noarch.rpm

    # Third, install Puppet
    yes | yum -y install puppet
}

function do_ubuntu {
    echo "Ubuntu codename: ${1}"

    # First, upgrade packages
    apt-get update
    apt-get -y dist-upgrade
    
    # Second, install PuppetLabs repository
    wget https://apt.puppetlabs.com/puppetlabs-release-pc1-${1}.deb
    dpkg -i puppetlabs-release-pc1-${1}.deb

    # Third, install Puppet
    apt-get -y install puppet
}

#### determine OS ####
case ${DISTRO} in
    CentOS)
        echo "CentOS detected"
        do_centos $(lsb_release -sr | cut -d'.' -f1)
        ;;
    Ubuntu)
        echo "Ubuntu detected"
        do_ubuntu $(lsb_release -sc)
        ;;
    *)
        echo "Unsupported distribution. Sorry..."
        exit 2
esac


