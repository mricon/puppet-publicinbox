# Public-inbox

[![Build Status](https://travis-ci.org/mricon/puppet-publicinbox.svg?branch=master)]
(https://travis-ci.org/mricon/puppet-publicinbox)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup](#setup)
4. [Reference](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Overview
Puppet module to manage Public-Inbox installation and configuration.

## Module Description
This module installs and configures [Public-Inbox](https://public-inbox.org).
It will install services and dependencies, plus manage the config file, but
will not init the repositories nor configure mail delivery/watching.

## Setup
It's expected that this module will be used with hiera, so the quickest way to
configure it for your environment is to add it to your Puppetfile:

```
mod 'mricon-publicinbox'
```

The minimal configuration bits that should go into hiera are the lists, e.g.:

```yaml
publicinbox::config::lists:
  lkml:
    address:
      - 'linux-kernel@vger.kernel.org'
    mainrepo: '/var/lib/public-inbox/lkml.git'
    url: 'https://lkml.kernel.org/'
    newsgroup: 'org.kernel.vger.linux-kernel'
```


## Reference
### publicinbox

#### `manage_git`

Whether to manage git installation (needed to clone the public-inbox repository).

Default: `true`

#### `version`

Version of public-inbox to install. Must match a ref in the public-inbox
repository.

Default: `master`

#### `install_dir`

Location where the public-inbox tree should be cloned.

Default: `/usr/local/share/public-inbox`

#### `source_repo`

Where to clone the public-inbox tree from. If you must carry local changes that
cannot be put into an extension, you can use your own repo location here.

Default: https://public-inbox.org

#### `make_test`

Whether to run "make test" after "make".

Default: `false`

#### `config_dir`
#### `config_dir_seltype`

Where the configuration files should be kept.

Defaults:
```yaml
publicinbox::config_dir: '/etc/public-inbox'
publicinbox::config_dir_seltype: undef
```


The SELinux type of the config dir, if you want to specify something other
than the default.

Default: `undef`

#### `var_dir`
#### `var_dir_owner`
#### `var_dir_group`
#### `var_dir_mode`
#### `var_dir_seltype`

Where the local data should be kept (git trees and indexes). The daemons are
not expected to write to it.

Defaults:
```yaml
publicinbox::var_dir: '/var/lib/public-inbox'
publicinbox::var_dir_owner: 'root'
publicinbox::var_dir_group: 'root'
publicinbox::var_dir_mode: '0775'
publicinbox::seltype: undef
```

#### `log_dir`
#### `log_dir_seltype`

Where the logs will go.

Defaults:
```yaml
publicinbox::log_dir: '/var/log/public-inbox'
publicinbox::log_dir_seltype: undef
```

#### `manage_user_group`
#### `damon_user`
#### `daemon_group`

User/group settings for the public-inbox listening daemons.

Defaults:
```yaml
publicinbox::manage_user_group: true
publicinbox::daemon_user: 'publicinbox'
publicinbox::daemon_group: 'publicinbox'
```

#### `enable_httpd`
#### `httpd_listen_port`
#### `enable_nntpd`
#### `nntpd_listen_port`

Whether to enable the daemons and on which port to run them.
The default httpd port is 8080 because it is assumed you will be running a
reverse-proxy in front of it.

Defaults:
```yaml
publicinbox::enable_httpd: true
publicinbox::httpd_listen_port: 8080
publicinbox::enable_nntpd: true
publicinbox::nntpd_listen_port: 119
```

### Config file parameters

You can manage the contents of /etc/public-inbox/config using the
publicinbox::config hash.

#### config::nntpserver

```yaml
publicinbox::config::nntpserver: 'nntp://news.example.com'
```

Will create:

```
[publicinbox]
    nntpserver=nntp://news.example.com
```


#### config::watch

```yaml
publicinbox::config::watch:
  spamcheck: 'spamc'
  watchspam: '/var/spool/mail/example'
```

Will create:

```
[publicinboxwatch]
    spamcheck=spamc
    watchspam=/var/spool/mail/example
```

#### config::lists

This uses the following general structure:

```yaml
publicinbox::config::lists:
  identifier:
    param:
      - 'value1'
      - 'value2'
      - 'etc'
```

Parameter values can be either strings or arrays and the module will do the
right thing regardless.

For example:

```yaml
publicinbox::config::lists:
  lkml:
    address: 'linux-kernel@vger.kernel.org'
    mainrepo: '/var/lib/public-inbox/lkml'
    url: 'https://lkml.example.com'
    newsgroup: 'org.kernel.vger.linux-kernel'
    watch: '/var/spool/mail/lkml'
    watchheader: 'List-Id:<linux-kernel.vger.kernel.org>'
```

Will create:

```
[publicinbox "lkml"]
    address=linux-kernel@vger.kernel.org
    mainrepo=/var/lib/public-inbox/lkml
    url=https://lkml.example.com
    newsgroup=org.kernel.vger.linux-kernel
    watch=/var/spool/mail/lkml
    watchheader=List-Id:<linux-kernel.vger.kernel.org>
```

## Limitations

Written and tested for CentOS 7 only, and will require some hacking to make it
work on other distros (patches welcome).
