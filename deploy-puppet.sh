#!/bin/bash
# set -x
# Adapted from https://puppetlabs.com/blog/bootstrap-rackspace-cloud-servers-puppet-and-libcloud
# and 
# https://www.digitalocean.com/community/tutorials/how-to-install-puppet-in-standalone-mode-on-centos-7
# and
# https://www.digitalocean.com/community/tutorials/how-to-set-up-a-masterless-puppet-environment-on-ubuntu-14-04


###################################################################################
#                                                                                 #
# some variables, some are used privately, some are set up using parameters       #
#                                                                                 #
###################################################################################                                                                                 

LSB=lsb_release
PACKAGES="puppet-agent git"
PUPPETPATH="/etc/profile.d/puppet-agent.sh"
PUPPETCONF="/etc/puppetlabs"
PUPPETMODULES="puppetlabs-stdlib"
PUPPETLABS="/opt/puppetlabs"


###################################################################################
#                                                                                 #
# process required parameters                                                     #
#                                                                                 #
###################################################################################

if [ "$#" -ne 12 ]; then
    echo "Illegal number of parameters"
    exit 5
else
    # if we get 5 parameters, check and set them, otherwise exit
    while getopts 'u:p:h:t:r:e:' opt; do
        case $opt in
            u) 
                USERNAME="$OPTARG"
                ;;
            p) 
                PASSWD="$OPTARG"
                ;;
            h) 
                REPOHOST="$OPTARG"
                ;;
            t) 
                TEAM="$OPTARG"
                ;;
            r) 
                REPONAME="$OPTARG"
                ;;
            e)
                ENVIRONMENT="$OPTARG"
                ;;
            *) 
                echo "unknown parameter"
                exit 4
            ;;
        esac
    done
fi

###################################################################################
#                                                                                 #
# distribution specific: add Puppet Collections repository                        #
#                                                                                 #
###################################################################################

#### Enterprise Linux ####

function do_el {
    echo "${DISTRO} version: ${1}"
    
    # First, upgrade packages
    yum -y update

    # Second, install PuppetLabs repository
    rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-pc1-el-${1}.noarch.rpm

    # Third, install Puppet
    yes | yum -y install ${PACKAGES}

    # Fourth, set up puppet
    do_puppet_repo_clone
}

#### Fedora ####

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

    # Third, install Puppet and git
    yes | ${PACKAGER} -y install ${PACKAGES}

    # Fourth, set up puppet
    do_puppet_repo_clone
}

#### Debian based ####

function do_debian_based {
    echo "${DISTRO} codename: ${1}"

    # First, upgrade packages
    apt-get update
    apt-get -y dist-upgrade
    
    # Second, install PuppetLabs repository
    wget https://apt.puppetlabs.com/puppetlabs-release-pc1-${1}.deb
    dpkg -i puppetlabs-release-pc1-${1}.deb
    apt-get update

    # Third, install Puppet and git
    export DEBIAN_FRONTEND=noninteractive
    apt-get -o Dpkg::Options::="--force-confnew" -y install ${PACKAGES}

    # Fourth, set up puppet
    do_puppet_repo_clone
}

###################################################################################
#                                                                                 #
# Puppet specific: clone repository, install modules from Puppet Forge, choose    #
# Puppet environment                                                              #
#                                                                                 #
###################################################################################

#### Clone the Puppet repository ####

function do_puppet_repo_clone {
    # change directory, make backup and clone the 'puppet' repo
    cd /etc
    if [ -d ${PUPPETCONF} ]; then
        mv ${PUPPETCONF}/ ${PUPPETCONF}-bak.$(date +%F-%s)
    fi
    git clone https://${USERNAME}:${PASSWD}@${REPOHOST}/${TEAM}/${REPONAME} ${PUPPETCONF}

    do_initial_puppet
}

#### Apply initial puppet site manifest ####

function do_initial_puppet {
    # Add /opt/puppetlabs/bin to $PATH variable
    if [ -f ${PUPPETPATH} ]; then
        source ${PUPPETPATH}
    else
        echo "${PUPPETPATH} doesn't exist, exiting..."
        exit 7
    fi
    # install puppet modules from the Forge
    do_puppetmodules_from_forge

    # apply the chosen puppet environment
    do_puppet_environment

    # run puppet to initially set up auto-deploy
    puppet apply ${PUPPETCONF}/code/environments/${ENVIRONMENT}/manifests
}

#### Install Puppet modules from Puppet Forge ####

function do_puppetmodules_from_forge {
    if [ -d ${PUPPETLABS}/puppet/modules ]; then
        puppet module install --target-dir ${PUPPETLABS}/puppet/modules ${PUPPETMODULES}

    else
        echo "${PUPPETLABS}/puppet/modules doesn't exist, exiting..."
        exit 6
    fi
}

#### Select specific Puppet environment ####

function do_puppet_environment {
    if [ ${ENVIRONMENT} == 'production' ]; then
        echo "default puppet environment chosen (${ENVIRONMENT}), no change there"
    else
        # check if chosen puppet environment directory exists
        if [ -d ${PUPPETCONF}/code/environments/${ENVIRONMENT} ]; then
            puppet resource file_line puppet-env path=${PUPPETCONF}/puppet/puppet.conf line="environment=${ENVIRONMENT}" match='^environment='
        else
            echo "chosen environment (${ENVIRONMENT}) directory doesn't exist, exiting..."
            exit 8
        fi
    fi
}

###################################################################################
#                                                                                 #
# generic functions                                                               #
#                                                                                 #
###################################################################################

#### brute force install 'redhat-lsb-core' ####

function do_lsb {
    echo "${LSB} wasn't found, probably a Red Hat family. Attempting install..."
    type -P "yum" > /dev/null && { echo "yum found, continuing..."; yum update -y; yum install -y redhat-lsb-core; } || { echo "yum not found, trying dnf"; dnf update -y; dnf install -y redhat-lsb-core; }
}

#### Check for required tool 'lsb_release' ####

type -P "${LSB}" > /dev/null && echo "${LSB} found, continuing..." || { echo "${LSB} not found, install first!"; do_lsb; }

##### Determine distro ####

DISTRO=$(lsb_release -si)

#### Select the current distribution ####

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


