class janus::source (
  $version,
  $repo = undef
) {

  require 'apt'
  require 'apt::source::cargomedia'
  require 'git'
  require 'build::automake'
  require 'build::autoconf'
  require 'build::libtool'
  require 'build::dev::libglib2'
  require 'build::dev::libjansson'

  $src_remote = $repo ? { undef => 'https://github.com/meetecho/janus-gateway.git',  default => $repo }

  package { [
    'libsrtp',
    'libwebsockets-dev',
    'usrsctp',
    'libmicrohttpd-dev',
    'libnice-dev',
    'libssl-dev',
    'libsofia-sip-ua-dev',
    'libopus-dev',
    'libogg-dev',
    'libini-config-dev',
    'libcollection-dev',
    'libavutil-dev',
    'libavcodec-dev',
    'libavformat-dev',
    'gengetopt',
  ]:
    provider => 'apt'
  }
  ->

  git::repository { 'Janus Gateway':
    remote    => $src_remote,
    directory => '/opt/janus/janus-gateway',
    revision  => $version,
  }
  ~>

  exec { 'Install Janus from Source':
    provider    => shell,
    command     => template("${module_name}/install.sh"),
    path        => ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    refreshonly => true,
    timeout     => 900,
  }
}
