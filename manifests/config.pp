# == Class: publicinbox::config
#
# Publicinbox configuration parameters
class publicinbox::config (
  Hash                     $lists                    = undef,

  Optional[Array]          $nntpserver               = undef,
  Optional[Array]          $css                      = undef,
  Optional[String]         $mailEditor               = undef,
  Optional[String]         $wwwlisting               = undef,
  Optional[Hash]           $watch                    = undef,

) inherits publicinbox {
  $config = "${publicinbox::config_dir}/config"

  file { $config:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/public-inbox-config.erb"),
    # Socket-based services make it a bit tricky to do this sanely with puppet
    notify  => [
      Exec['publicinbox-systemd-nudge-httpd'],
      Exec['publicinbox-systemd-nudge-nntpd'],
    ],
  }

  exec { 'publicinbox-systemd-nudge-httpd':
    command     => 'systemctl kill -s SIGHUP public-inbox-httpd@1.service',
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
  }

  exec { 'publicinbox-systemd-nudge-nntpd':
    command     => 'systemctl kill -s SIGHUP public-inbox-nntpd@1.service',
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
  }

}

