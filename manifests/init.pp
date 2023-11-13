# == Class: publicinbox
#
# Main publicinbox init class
class publicinbox (
  Boolean                  $manage_git          = $publicinbox::params::manage_git,
  String                   $version             = $publicinbox::params::version,

  Pattern['^\/']           $install_dir         = $publicinbox::params::install_dir,
  Pattern['^\/']           $config_dir          = $publicinbox::params::config_dir,
  Optional[String]         $config_dir_seltype  = $publicinbox::params::config_dir_seltype,
  String                   $config_dir_owner    = $publicinbox::params::config_dir_owner,
  String                   $config_dir_group    = $publicinbox::params::config_dir_group,
  String                   $config_dir_mode     = $publicinbox::params::config_dir_mode,
  Pattern['^\/']           $config_file         = $publicinbox::params::config_file,
  Boolean                  $manage_config_file  = $publicinbox::params::manage_config_file,
  String                   $config_file_owner   = $publicinbox::params::config_file_owner,
  String                   $config_file_group   = $publicinbox::params::config_file_group,
  String                   $config_file_mode    = $publicinbox::params::config_file_mode,
  Pattern['^\/']           $var_dir             = $publicinbox::params::var_dir,
  Optional[String]         $var_dir_seltype     = $publicinbox::params::var_dir_seltype,
  String                   $var_dir_owner       = $publicinbox::params::var_dir_owner,
  String                   $var_dir_group       = $publicinbox::params::var_dir_group,
  String                   $var_dir_mode        = $publicinbox::params::var_dir_mode,
  Pattern['^\/']           $log_dir             = $publicinbox::params::log_dir,
  Optional[String]         $log_dir_seltype     = $publicinbox::params::log_dir_seltype,
  String                   $source_repo         = $publicinbox::params::source_repo,
  Boolean                  $make_test           = $publicinbox::params::make_test,

  String                   $daemon_user         = $publicinbox::params::daemon_user,
  String                   $daemon_group        = $publicinbox::params::daemon_group,
  Boolean                  $enable_httpd        = $publicinbox::params::enable_httpd,
  Integer                  $httpd_listen_port   = $publicinbox::params::httpd_listen_port,
  Optional[String]         $httpd_daemon_flags  = $publicinbox::params::httpd_daemon_flags,
  Boolean                  $enable_nntpd        = $publicinbox::params::enable_nntpd,
  Variant[Integer,Array]   $nntpd_listen_port   = $publicinbox::params::nntpd_listen_port,
  Optional[String]         $nntpd_daemon_flags  = $publicinbox::params::nntpd_daemon_flags,
  Boolean                  $enable_imapd        = $publicinbox::params::enable_imapd,
  Variant[Integer,Array]   $imapd_listen_port   = $publicinbox::params::imapd_listen_port,
  Optional[String]         $imapd_daemon_flags  = $publicinbox::params::imapd_daemon_flags,
  Boolean                  $enable_pop3d        = $publicinbox::params::enable_pop3d,
  Variant[Integer,Array]   $pop3d_listen_port   = $publicinbox::params::pop3d_listen_port,
  Optional[String]         $pop3d_daemon_flags  = $publicinbox::params::pop3d_daemon_flags,
  Boolean                  $enable_watch        = $publicinbox::params::enable_watch,

  Boolean                  $manage_daemon_ug    = $publicinbox::params::manage_daemon_ug,
  Boolean                  $manage_var_ug       = $publicinbox::params::manage_var_ug,

  Array                    $os_packages         = $publicinbox::params::os_packages,
  Array                    $cpanm_packages      = $publicinbox::params::cpanm_packages,

) inherits publicinbox::params {

  anchor { "${module_name}::begin": }
  -> class { "${module_name}::install": }
  -> class { "${module_name}::config": }
  -> anchor { "${module_name}::end": }
}
