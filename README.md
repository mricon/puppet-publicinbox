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

#### `config_dir`

Where the configuration files should be kept.

Default: `/etc/public-inbox`

#### `var_dir`

Where the local data should be kept (git trees and indexes). The daemons are
not expected to write to it.

Default: `/var/lib/public-inbox`

#### `log_dir`

Where the logs will go.

Default: `/var/log/public-inbox`

#### `source_repo`

Where to clone the public-inbox tree from. If you must carry local changes that
cannot be put into an extension, you can use your own repo location here.

Default: https://public-inbox.org

#### `make_test`

Whether to run "make test" after "make".

Default: `false`

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
