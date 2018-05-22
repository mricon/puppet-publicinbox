# == Class: publicinbox::params
#
# This is a container class with default parameters for publicinbox class
class publicinbox::params {
  $manage_git          = true
  $version             = 'master'
  $install_dir         = '/usr/local/share/public-inbox'
  $config_dir          = '/etc/public-inbox'
  $var_dir             = '/var/lib/public-inbox'
  $log_dir             = '/var/log/public-inbox'
  $source_repo         = 'https://public-inbox.org'
  $make_test           = false
  $manage_user         = true
  $runuser             = 'publicinbox'
  $manage_group        = true
  $rungroup            = 'publicinbox'
  $enable_httpd        = true
  $httpd_listen_port   = 8080
  $enable_nntpd        = true
  $nntpd_listen_port   = 119
}
