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
  $var_dir_owner       = 'root'
  $var_dir_group       = 'root'
  $var_dir_mode        = '0775'
  $log_dir             = '/var/log/public-inbox'
  $log_dir_seltype     = undef
  $source_repo         = 'https://public-inbox.org'
  $make_test           = false
  $manage_user_group   = true
  $daemon_user         = 'publicinbox'
  $daemon_group        = 'publicinbox'
  $enable_httpd        = true
  $httpd_listen_port   = 8080
  $enable_nntpd        = true
  $nntpd_listen_port   = 119
  $enable_watch        = false
  $watch_user          = 'piwatch'
}
