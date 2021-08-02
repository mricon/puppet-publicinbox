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
  Optional[Hash]           $extindex                 = undef,
  Optional[String]         $unmanaged_raw_include    = undef,

) inherits publicinbox {
  exec { 'public-inbox-reload.sh':
    command     => '/usr/local/bin/public-inbox-reload.sh',
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
    require     => File['/usr/local/bin/public-inbox-reload.sh'],
  }

  if $publicinbox::manage_config_file {
    $config_watcher_enable = false
    $config_watcher_ensure = 'stopped'
    concat::fragment { 'publicinbox_config_preamble':
      target  => $publicinbox::config_file,
      content => template("${module_name}/public-inbox-config-preamble.erb"),
      order   => 100,
    }

    if $lists {
      $lists.each |String $listname, $listoptions| {
        publicinbox::config::list { $listname:
          listoptions => $listoptions,
        }
      }
    }

    concat { $publicinbox::config_file:
      ensure  => present,
      owner   => $publicinbox::config_file_owner,
      group   => $publicinbox::config_file_group,
      mode    => $publicinbox::config_file_mode,
      notify  => Exec['public-inbox-reload.sh'],
      require => File[$publicinbox::config_dir],
    }

  } else {
    if $unmanaged_raw_include {
      file { "${publicinbox::config_dir}/config.include":
        ensure  => present,
        owner   => $publicinbox::config_file_owner,
        group   => $publicinbox::config_file_group,
        mode    => $publicinbox::config_file_mode,
        content => "# MANAGED BY PUPPET\n${unmanaged_raw_include}",
        notify  => Exec['public-inbox-reload.sh'],
        require => File[$publicinbox::config_dir],
      }
      exec { 'public-inbox-raw-include':
        command => "git config --file ${publicinbox::config_file} --add include.path ${publicinbox::config_dir}/config.include",
        unless  => "git config --file ${publicinbox::config_file} --get-all include.path | egrep -q ^${publicinbox::config_dir}/config.include$",
        path    => ['/usr/bin', '/bin'],
        require => File[$publicinbox::config_dir],
      }
    }
    # Use git-config to set global options
    $config_watcher_enable = true
    $config_watcher_ensure = 'running'
  }

  service { 'public-inbox-config-watcher.path':
    ensure => $config_watcher_ensure,
    enable => $config_watcher_enable,
  }
}

define publicinbox::config::list($listoptions, $init_if_missing=false) {
  if $publicinbox::manage_config_file {
    $listname = $name
    if $listoptions['priority'] {
      $order = $listoptions['priority']
    } else {
      $order = 1
    }
    concat::fragment { "publicinbox_list_${name}":
      target  => $publicinbox::config_file,
      content => template("${module_name}/public-inbox-config-list.erb"),
      order   => $order,
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
}
