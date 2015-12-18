# bootstrap
An attempt to bootstrap my Linux machines with the settings I like

## What is it?
The idea is that by using a oneliner you can fetch a _bash_ script that adds the official [Puppet Labs repository](https://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html) for a distribution. I intend to use the _Puppet Collections_ so I can choose when to migrate to a newer release at my convenience.

After adding the _Puppet Labs_ repository the Puppet agent is installed. Using _git_, a puppet repository is cloned and applied. This puppet repository can contain the puppet configuration in any way you like. I've dealt with Puppet masters and am leaning towards masterless Puppet with this script.

### assumptions
The bash script currently uses a _team_ and a _user_ to clone a private _git_ repository at [Bitbucket](https://bitbucket.org). It also focuses on recent distributions of Red Hat Enterprise Linux, CentOS, Fedora, Debian and Ubuntu.

If it doesn't fit your needs, contribute or fork but please share.

### getting started
Simply execute a oneliner with some parameters. For example as a user with sudo permissions:
```
curl https://raw.githubusercontent.com/D43m0n/bootstrap/master/deploy-puppet.sh | sudo bash /dev/stdin -u <username> -p <password> -h <hostname> -t <team name> -r <repository name>
```

Al the default output is printed on `stdout`.