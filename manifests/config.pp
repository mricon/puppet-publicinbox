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

) inherits publicinbox {
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

    exec { 'public-inbox-reload.sh':
      command     => '/usr/local/bin/public-inbox-reload.sh',
      path        => ['/usr/bin', '/bin'],
      refreshonly => true,
      require     => File['/usr/local/bin/public-inbox-reload.sh'],
    }
  } else {
    # Use git-config to set global options
    if $global {
      $global.each |String $gname, $gval| {
        exec { "public-inbox-set-global-${gname}":
          command => "git config --file ${publicinbox::config_file} --replace-all publicinbox.${gname} \"${gval}\"",
          onlyif  => "test `git config --file ${publicinbox::config_file} --get publicinbox.${gname}` != \"${gval}\"",
          path    => ['/usr/bin', '/bin'],
          require => File[$publicinbox::config_dir],
        }
      }
    }
    if $extindex {
      $extindex.each |String $einame, $eiopts| {
        $eiopts.each |String $eiparam, $eival| {
          exec { "public-inbox-set-extindex-${einame}-${eiparam}":
            command => "git config --file ${publicinbox::config_file} --replace-all extindex.${einame}.${eiparam} \"${eival}\"",
            onlyif  => "test `git config --file ${publicinbox::config_file} --get extindex.${einame}.${eiparam}` != \"${eival}\"",
            path    => ['/usr/bin', '/bin'],
            require => File[$publicinbox::config_dir],
          }
        }
      }
    }
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
