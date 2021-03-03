# == Class: publicinbox::params
#
# This is a container class with default parameters for publicinbox class
class publicinbox::params {
  $manage_git          = true
  $version             = 'master'
  $install_dir         = '/usr/local/share/public-inbox'
  $config_dir          = '/etc/public-inbox'
  $config_dir_seltype  = undef
  $var_dir             = '/var/lib/public-inbox'
  $var_dir_seltype     = undef
  $var_dir_owner       = 'archiver'
  $var_dir_group       = 'archiver'
  $var_dir_mode        = '0775'
  $log_dir             = '/var/log/public-inbox'
  $log_dir_seltype     = undef
  $log_dir_owner       = 'root'
  $log_dir_group       = 'root'
  $source_repo         = 'https://public-inbox.org'
  $make_test           = false
  $daemon_user         = 'publicinbox'
  $daemon_group        = 'publicinbox'
  $enable_httpd        = true
  $httpd_listen_port   = 8080
  $httpd_daemon_flags  = undef
  $enable_nntpd        = true
  $nntpd_listen_port   = 119
  $nntpd_daemon_flags  = undef
  $enable_watch        = false

  $manage_daemon_ug    = true
  $manage_var_ug       = true
}
