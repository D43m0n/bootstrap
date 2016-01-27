# bootstrap
An attempt to bootstrap my Linux machines with the settings I like

## what is it?
The idea is that by using a oneliner you can fetch a _bash_ script that adds the official [Puppet Labs repository](https://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html) for a distribution. I intend to use the _Puppet Collections_ (version 1 currently) so I can choose when to migrate to a newer release at my convenience.

After updating packages and adding the _Puppet Labs_ repository, the Puppet agent is installed. Using _git_, a puppet repository is cloned and applied.  This puppet repository can contain the puppet configuration in any way you like. Additional puppet modules from the [Forge](https://forge.puppetlabs.com) can be installed before applying the _site manifest_. These are installed in the _Puppet Collections_ installdir (using `$modulepath`). In this way they are available at all times, and not stored with your own code. You may also choose to apply a _site manifest_ from a different _environment_. I've dealt with Puppet masters and am leaning towards masterless Puppet with this script.

### assumptions
The bash script currently uses a _team_ and a _user_ to clone a private _git_ repository at [Bitbucket](https://bitbucket.org). It also focuses on recent distributions of Red Hat Enterprise Linux, CentOS, Fedora, Debian and Ubuntu. The default _environment_ for `puppet apply` is _production_.

If it doesn't fit your needs, contribute or fork but please share.

### getting started
Simply execute a oneliner with some parameters. For example as a user with sudo permissions:
```
curl https://raw.githubusercontent.com/D43m0n/bootstrap/master/deploy-puppet.sh | sudo bash /dev/stdin -u <username> -p <password> -h <hostname> -t <team name> -r <repository name> -e <environment>
```

All the default output is printed on `stdout`.