# == Class: publicinbox::params
#
# This is a container class with default parameters for publicinbox class
class publicinbox::params {
  $manage_git          = true
  $version             = 'master'
  $install_dir         = '/usr/local/share/public-inbox'
  $config_dir          = '/etc/public-inbox'
  $config_dir_seltype  = undef
  $config_dir_owner    = 'root'
  $config_dir_group    = 'root'
  $config_dir_mode     = '0755'
  $config_file         = "${config_dir}/config"
  $manage_config_file  = true
  $config_file_owner   = $config_dir_owner
  $config_file_group   = $config_dir_group
  $config_file_mode    = '0644'
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

  $os_packages         = [
      'xapian-core',
      'xapian-core-devel',
      'expat-devel',
      'libxml2-devel',
      'gcc-c++',
      'perl-Plack',
  ]
  $cpanm_packages      = [
      'Date::Parse',
      'Email::MIME',
      'Email::MIME::ContentType',
      'Email::Address::XS',
      'Encode::MIME::Header',
      'Parse::RecDescent',
      'BSD::Resource',
      'Plack::Middleware::ReverseProxy',
      'Plack::Middleware::Deflater',
      'URI::Escape',
      'Search::Xapian',
      'IO::Compress::Gzip',
      'DBI',
      'DBD::SQLite',
      'Danga::Socket',
      'Net::Server',
      'Filesys::Notify::Simple',
      'Inline::C',
      'IPC::Run',
      'XML::Feed',
      'Linux::Inotify2',
      'Mail::IMAPClient',
      'Mail::IMAPClient::BodyStructure',
  ]
}
