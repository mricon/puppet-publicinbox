# == Class: publicinbox::install
#
# Install class for publicinbox
class publicinbox::install inherits publicinbox {
  include ::cpanm

  if $publicinbox::manage_git {
    include ::git
  }

  case $publicinbox::version {
    'latest': {
      $vcsrepo_ensure = 'latest'
      $revision = 'master'
    }
    default: {
      $vcsrepo_ensure = 'present'
      $revision       = $publicinbox::version
    }
  }

  file { $publicinbox::install_dir:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  vcsrepo { $publicinbox::install_dir:
    ensure   => $vcsrepo_ensure,
    provider => 'git',
    source   => $publicinbox::source_repo,
    revision => $revision,
    force    => true,
    require  => File[$publicinbox::install_dir],
    notify   => Exec['publicinbox-perl-Makefile.PL'],
  }

  package { [
    'xapian-core',
    'xapian-core-devel',
    'expat-devel',
    'libxml2-devel',
    'gcc-c++',
    'perl-Plack',
  ]:
    ensure => installed,
  }

  cpanm { [
    'Date::Parse',
    'Email::MIME',
    'Email::MIME::ContentType',
    'Encode::MIME::Header',
    'Socket6',
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
  ]:
    ensure  => present,
    require => [
      Package['xapian-core'],
      Package['xapian-core-devel'],
      Package['perl-Plack'],
      Package['gcc-c++'],
      Package['expat-devel'],
      Package['libxml2-devel'],
    ],
    before  => Exec['publicinbox-perl-Makefile.PL'],
  }

  exec { 'publicinbox-perl-Makefile.PL':
    command => 'perl Makefile.PL',
    path    => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    cwd     => $publicinbox::install_dir,
    creates => "${publicinbox::install_dir}/Makefile",
    notify  => Exec['publicinbox-make'],
  }

  if $publicinbox::make_test {
    $next_exec = 'publicinbox-make-test'
  } else {
    $next_exec = 'publicinbox-make-install'
  }

  exec { 'publicinbox-make':
    command     => 'make',
    path        => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    cwd         => $publicinbox::install_dir,
    refreshonly => true,
    notify      => Exec[$next_exec],
  }

  exec { 'publicinbox-make-test':
    command     => 'make test',
    path        => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    cwd         => $publicinbox::install_dir,
    refreshonly => true,
    notify      => Exec['publicinbox-make-install'],
  }

  exec { 'publicinbox-make-install':
    command     => 'make install',
    path        => [ '/bin', '/sbin', '/usr/bin', '/usr/sbin' ],
    cwd         => $publicinbox::install_dir,
    creates     => '/usr/local/bin/public-inbox-init',
    refreshonly => true,
  }

  if $publicinbox::manage_daemon_ug {
    group { $publicinbox::daemon_group:
      ensure => present,
      system => true,
    }
    user { $publicinbox::daemon_user:
      ensure => present,
      gid    => $publicinbox::daemon_group,
      home   => $publicinbox::var_dir,
      shell  => '/sbin/nologin',
      system => true,
    }
  }
  if $publicinbox::manage_var_ug {
    group { $publicinbox::var_dir_group:
      ensure => present,
      system => true,
    }
    user { $publicinbox::var_dir_owner:
      ensure => present,
      gid    => $publicinbox::var_dir_group,
      home   => $publicinbox::var_dir,
      shell  => '/sbin/nologin',
      system => true,
    }
  }

  file { $publicinbox::var_dir:
    ensure  => directory,
    owner   => $publicinbox::var_dir_owner,
    group   => $publicinbox::var_dir_group,
    mode    => $publicinbox::var_dir_mode,
    seltype => $publicinbox::var_dir_seltype,
  }

  file { $publicinbox::log_dir:
    ensure  => directory,
    owner   => $publicinbox::daemon_user,
    group   => $publicinbox::daemon_group,
    mode    => '0700',
    seltype => $publicinbox::log_dir_seltype,
  }

  file { $publicinbox::config_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    seltype => $publicinbox::config_dir_seltype,
  }

  file { '/etc/systemd/system/public-inbox-httpd.socket':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/public-inbox-httpd.socket.erb"),
    notify  => Exec['publicinbox-systemd-reload'],
  }

  file { '/etc/logrotate.d/public-inbox.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/logrotate.conf.erb"),
    require => File[$publicinbox::log_dir],
  }

  $run_dir = '/var/run/public-inbox'

  file { '/etc/tmpfiles.d/public-inbox.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => "d ${run_dir} 0770 root ${publicinbox::daemon_group}\n",
      notify  => Exec['publicinbox-systemd-tmpfiles-create'],
    }

  $config = "${publicinbox::config_dir}/config"

  file { '/etc/systemd/system/public-inbox-httpd@.service':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/public-inbox-httpd@.service.erb"),
    require => [
      File[$publicinbox::config_dir],
      File[$publicinbox::log_dir],
      File['/etc/tmpfiles.d/public-inbox.conf'],
      File['/etc/systemd/system/public-inbox-httpd.socket'],
    ],
    notify  => Exec['publicinbox-systemd-reload'],
  }

  file { '/etc/systemd/system/public-inbox-nntpd.socket':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/public-inbox-nntpd.socket.erb"),
    notify  => Exec['publicinbox-systemd-reload'],
  }

  file { '/etc/systemd/system/public-inbox-nntpd@.service':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/public-inbox-nntpd@.service.erb"),
    require => [
      File[$publicinbox::config_dir],
      File[$publicinbox::log_dir],
      File['/etc/tmpfiles.d/public-inbox.conf'],
      File['/etc/systemd/system/public-inbox-nntpd.socket'],
    ],
    notify  => Exec['publicinbox-systemd-reload'],
  }

  exec { 'publicinbox-systemd-reload':
    command     => 'systemctl daemon-reload',
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
  }

  exec { 'publicinbox-systemd-tmpfiles-create':
    command     => 'systemd-tmpfiles --create /etc/tmpfiles.d/public-inbox.conf',
    path        => ['/usr/bin', '/bin'],
    refreshonly => true,
  }

  if $publicinbox::enable_httpd {
    $httpd_enable = true
    $httpd_ensure = 'running'
  } else {
    $httpd_enable = false
    $httpd_ensure = 'stopped'
  }

  service { 'public-inbox-httpd.socket':
    ensure => $httpd_ensure,
    enable => $httpd_enable,
  }

  if $publicinbox::enable_nntpd {
    $nntpd_enable = true
    $nntpd_ensure = 'running'
  } else {
    $nntpd_enable = false
    $nntpd_ensure = 'stopped'
  }

  service { 'public-inbox-nntpd.socket':
    ensure => $nntpd_ensure,
    enable => $nntpd_enable,
  }

  file { '/etc/systemd/system/public-inbox-watch.service':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/public-inbox-watch.service.erb"),
    require => [
      File[$publicinbox::config_dir],
    ],
    notify  => Exec['publicinbox-systemd-reload'],
  }

  if $publicinbox::enable_watch {
    $watch_enable = true
    $watch_ensure = 'running'
  } else {
    $watch_enable = false
    $watch_ensure = 'stopped'
  }

  service { 'public-inbox-watch.service':
    ensure => $watch_ensure,
    enable => $watch_enable,
  }
}
