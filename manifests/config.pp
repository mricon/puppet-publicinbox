# == Class: publicinbox::config
#
# Publicinbox configuration parameters
class publicinbox::config (
  Optional[Hash]           $lists                    = undef,

  Optional[Array]          $nntpserver               = undef,
  Optional[Array]          $css                      = undef,
  Optional[String]         $maileditor               = undef,
  Optional[String]         $wwwlisting               = undef,
  Optional[Hash]           $watch                    = undef,
  Optional[Hash]           $global                   = undef,

) inherits publicinbox {
  $config = "${publicinbox::config_dir}/config"

  concat::fragment { 'publicinbox_config_preamble':
    target  => $config,
    content => template("${module_name}/public-inbox-config-preamble.erb"),
    order   => 10,
  }

  if $lists {
    $lists.each |String $listname, $listoptions| {
      publicinbox::config::list { $listname:
        listoptions => $listoptions,
      }
    }
  }

  concat { $config:
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    # Socket-based services make it a bit tricky to do this sanely with puppet
    notify => [
      Exec['publicinbox-systemd-nudge-httpd'],
      Exec['publicinbox-systemd-nudge-nntpd'],
      Exec['publicinbox-systemd-nudge-watch'],
    ],
  }

  if $::publicinbox::enable_httpd {
    exec { 'publicinbox-systemd-nudge-httpd':
      command     => 'systemctl restart public-inbox-httpd@*.service',
      path        => ['/usr/bin', '/bin'],
      refreshonly => true,
    }
  } else {
    exec { 'publicinbox-systemd-nudge-httpd':
      command     => '/bin/true',
      path        => ['/usr/bin', '/bin'],
      refreshonly => true,
    }
  }

  if $::publicinbox::enable_nntpd {
    exec { 'publicinbox-systemd-nudge-nntpd':
      command     => 'systemctl reload public-inbox-nntpd@*.service',
      path        => ['/usr/bin', '/bin'],
      refreshonly => true,
    }
  } else {
    exec { 'publicinbox-systemd-nudge-nntpd':
      command     => '/bin/true',
      path        => ['/usr/bin', '/bin'],
      refreshonly => true,
    }
  }

  if $::publicinbox::enable_watch {
    exec { 'publicinbox-systemd-nudge-watch':
      command     => 'systemctl restart public-inbox-watch.service',
      path        => ['/usr/bin', '/bin'],
      refreshonly => true,
    }
  } else {
    exec { 'publicinbox-systemd-nudge-watch':
      command     => '/bin/true',
      path        => ['/usr/bin', '/bin'],
      refreshonly => true,
    }
  }
}

define publicinbox::config::list($listoptions, $init_if_missing=false) {
  $config = "${publicinbox::config_dir}/config"
  $listname = $name
  concat::fragment { "publicinbox_list_${name}":
    target  => $config,
    content => template("${module_name}/public-inbox-config-list.erb"),
    order   => 1,
  }
  if $init_if_missing {
    if $listoptions['indexlevel'] {
      $indexlevel = $listoptions['indexlevel']
    } else {
      $indexlevel = 'full'
    }
    exec { "public_inbox_init_${name}":
      command     => "public-inbox-init -V2 -L ${indexlevel} ${name} ${publicinbox::var_dir}/${name} null null",
      path        => ['/usr/bin', '/usr/local/bin', '/bin'],
      creates     => "${publicinbox::var_dir}/${name}/msgmap.sqlite3",
      user        => $publicinbox::var_dir_owner,
      group       => $publicinbox::var_dir_group,
      environment => [
        "PI_CONFIG=/tmp/.public-inbox-init-${name}"
      ],
    }
    file { "/tmp/.public-inbox-init-${name}":
      ensure  => absent,
      require => Exec["public_inbox_init_${name}"],
    }
  }
}
