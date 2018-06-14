# == Class: publicinbox
#
# Main publicinbox init class
class publicinbox (
  Boolean                  $manage_git          = $publicinbox::params::manage_git,
  String                   $version             = $publicinbox::params::version,

  Pattern['^\/']           $install_dir         = $publicinbox::params::install_dir,
  Pattern['^\/']           $config_dir          = $publicinbox::params::config_dir,
  Optional[String]         $config_dir_seltype  = $publicinbox::params::config_dir_seltype,
  Pattern['^\/']           $var_dir             = $publicinbox::params::var_dir,
  Optional[String]         $var_dir_seltype     = $publicinbox::params::var_dir_seltype,
  String                   $var_dir_owner       = $publicinbox::params::var_dir_owner,
  String                   $var_dir_group       = $publicinbox::params::var_dir_group,
  String                   $var_dir_mode        = $publicinbox::params::var_dir_mode,
  Pattern['^\/']           $log_dir             = $publicinbox::params::log_dir,
  Optional[String]         $log_dir_seltype     = $publicinbox::params::log_dir_seltype,
  String                   $source_repo         = $publicinbox::params::source_repo,
  Boolean                  $make_test           = $publicinbox::params::make_test,

  Boolean                  $manage_user_group   = $publicinbox::params::manage_user_group,
  String                   $daemon_user         = $publicinbox::params::daemon_user,
  String                   $daemon_group        = $publicinbox::params::daemon_group,
  Boolean                  $enable_httpd        = $publicinbox::params::enable_httpd,
  Integer                  $httpd_listen_port   = $publicinbox::params::httpd_listen_port,
  Boolean                  $enable_nntpd        = $publicinbox::params::enable_nntpd,
  Integer                  $nntpd_listen_port   = $publicinbox::params::nntpd_listen_port,
  Boolean                  $enable_watch        = $publicinbox::params::enable_watch,
  String                   $watch_user          = $publicinbox::params::watch_user,

) inherits publicinbox::params {

  anchor { "${module_name}::begin": }
  -> class { "${module_name}::install": }
  -> class { "${module_name}::config": }
  -> anchor { "${module_name}::end": }
}
