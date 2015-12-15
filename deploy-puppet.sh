#!/bin/bash
# set -x
# Adapted from https://puppetlabs.com/blog/bootstrap-rackspace-cloud-servers-puppet-and-libcloud
# and https://www.digitalocean.com/community/tutorials/how-to-install-puppet-in-standalone-mode-on-centos-7

LSB=lsb_release
function do_lsb {
    echo "${LSB} wasn't found, probably a Red Hat family. Attempting install..."
    type -P "yum" > /dev/null && { echo "yum found, continuing..."; yum update -y; yum install -y redhat-lsb-core; } || { echo "yum not found, trying dnf"; dnf update -y; dnf install -y redhat-lsb-core; }
}

#### functions ####
function do_el {
    echo "${DISTRO} version: ${1}"
    
    # First, upgrade packages
    yum -y update

    # Second, install PuppetLabs repository
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-pc1-el-${1}.noarch.rpm

    # Third, install Puppet
    yes | yum -y install puppet
}

function do_fedora {
    echo "${DISTRO} version: ${1}"
    
    case ${1} in
        2[01])
            echo "This ${DISTRO} version uses yum"
            PACKAGER=yum
            ;;
        2[234])
            echo "Puppet has no full support yet..."
            exit 3
            echo "This ${DISTRO} version uses dnf"
            PACKAGER=dnf
            ;;
        *)
            echo "${DISTRO} version not supported by Puppet repo..."
            exit 3
    esac

    # First, upgrade packages
    ${PACKAGER} -y update

    # Second, install PuppetLabs repository
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-pc1-fedora-${1}.noarch.rpm

    # Third, install Puppet
    yes | ${PACKAGER} -y install puppet
}

function do_debian_based {
    echo "${DISTRO} codename: ${1}"

    # First, upgrade packages
    apt-get update
    apt-get -y dist-upgrade
    
    # Second, install PuppetLabs repository
    wget https://apt.puppetlabs.com/puppetlabs-release-pc1-${1}.deb
    dpkg -i puppetlabs-release-pc1-${1}.deb

    # Third, install Puppet
    apt-get -y install puppet
}

#### Check for required tool ####
type -P "${LSB}" > /dev/null && echo "${LSB} found, continuing..." || { echo "${LSB} not found, install first!"; do_lsb; }

##### Determine distro ####
DISTRO=$(lsb_release -si)

case ${DISTRO} in
    CentOS|RedHatEnterpriseServer)
        echo "${DISTRO} detected"
        do_el $(lsb_release -sr | cut -d'.' -f1)
        ;;
    Fedora)
        echo "${DISTRO} detected"
        do_fedora $(lsb_release -sr | cut -d'.' -f1)
        ;;
    Ubuntu|Debian)
        echo "${DISTRO} detected"
        do_debian_based $(lsb_release -sc)
        ;;
    *)
        echo "Unsupported distribution. Sorry..."
        exit 2
esac


