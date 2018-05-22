# == Class: publicinbox
#
# Main publicinbox init class
class publicinbox (
  Boolean                  $manage_git          = $publicinbox::params::manage_git,
  String                   $version             = $publicinbox::params::version,

  Pattern['^\/']           $install_dir         = $publicinbox::params::install_dir,
  Pattern['^\/']           $config_dir          = $publicinbox::params::config_dir,
  Pattern['^\/']           $var_dir             = $publicinbox::params::var_dir,
  Pattern['^\/']           $log_dir             = $publicinbox::params::log_dir,
  String                   $source_repo         = $publicinbox::params::source_repo,
  Boolean                  $make_test           = $publicinbox::params::make_test,

  Boolean                  $manage_user         = $publicinbox::params::manage_user,
  String                   $runuser             = $publicinbox::params::runuser,
  Boolean                  $manage_group        = $publicinbox::params::manage_group,
  String                   $rungroup            = $publicinbox::params::rungroup,
  Boolean                  $enable_httpd        = $publicinbox::params::enable_httpd,
  Integer                  $httpd_listen_port   = $publicinbox::params::httpd_listen_port,
  Boolean                  $enable_nntpd        = $publicinbox::params::enable_nntpd,
  Integer                  $nntpd_listen_port   = $publicinbox::params::nntpd_listen_port,

) inherits publicinbox::params {

  anchor { "${module_name}::begin": }
  -> class { "${module_name}::install": }
  -> class { "${module_name}::config": }
  -> anchor { "${module_name}::end": }
}
