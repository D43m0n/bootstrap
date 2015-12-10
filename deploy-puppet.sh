#!/bin/bash
# set -x
# Adapted from https://puppetlabs.com/blog/bootstrap-rackspace-cloud-servers-puppet-and-libcloud
# and https://www.digitalocean.com/community/tutorials/how-to-install-puppet-in-standalone-mode-on-centos-7

#### Check for required tool ####
LSB=lsb_release
type -P "${LSB}" > /dev/null && echo "${LSB} found, continuing..." || { echo "${LSB} not found, install first! Now exiting..."; exit 1; }

#### functions ####
function do_el {
    echo "Enterprise Linux version: ${1}"
    
    # First, upgrade packages
    yum -y update

    # Second, install PuppetLabs repository
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-pc1-el-${1}.noarch.rpm

    # Third, install Puppet
    yes | yum -y install puppet
}

function do_fedora {
    echo "Fedora version: ${1}"
    
    case ${1} in
        [20-21])
            echo "This Fedora version uses yum"
            PACKAGER=yum
            ;;
        [22-29])
            echo "Puppet has no full support yet..."
            exit 3
            echo "This Fedora version uses dnf"
            PACKAGER=dnf
            ;;
        *)
            echo "Fedora version not supported by Puppet repo..."
            exit 3
    esac

    # First, upgrade packages
    ${PACKAGER} -y update

    # Second, install PuppetLabs repository
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-pc1-fedora-${1}.noarch.rpm

    # Third, install Puppet
    yes | ${PACKAGER} -y install puppet
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

##### Determine distro ####
DISTRO=$(lsb_release -si)

case ${DISTRO} in
    CentOS|RedHatEnterpriseServer)
        echo "Enterprise Linux detected"
        do_el $(lsb_release -sr | cut -d'.' -f1)
        ;;
    Fedora)
        echo "Fedora detected"
        do_fedora $(lsb_release -sr | cut -d'.' -f1)
        ;;
    Ubuntu)
        echo "Ubuntu detected"
        do_ubuntu $(lsb_release -sc)
        ;;
    *)
        echo "Unsupported distribution. Sorry..."
        exit 2
esac


