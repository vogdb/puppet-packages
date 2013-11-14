define nginx::resource::vhost(
  $ensure                 = 'enable',
  $listen_ip              = '*',
  $listen_port            = '80',
  $listen_options         = undef,
  $ipv6_enable            = false,
  $ipv6_listen_ip         = '::',
  $ipv6_listen_port       = '80',
  $ipv6_listen_options    = 'default',
  $ssl                    = false,
  $ssl_cert               = undef,
  $ssl_key                = undef,
  $ssl_port		          = '443',
  $proxy                  = undef,
  $proxy_read_timeout     = $nginx::params::nx_proxy_read_timeout,
  $index_files            = ['index.html', 'index.htm', 'index.php'],
  $server_name            = [$name],
  $www_root               = undef,
  $rewrite_www_to_non_www = false,
  $location_cfg_prepend   = undef,
  $location_cfg_append    = undef,
  $try_files              = undef
) {

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  # Add IPv6 Logic Check - Nginx service will not start if ipv6 is enabled
  # and support does not exist for it in the kernel.
  if ($ipv6_enable == 'true') and ($ipaddress6)  {
    warning('nginx: IPv6 support is not enabled or configured properly')
  }

  # Check to see if SSL Certificates are properly defined.
  if ($ssl == 'true') {
    if ($ssl_cert == undef) or ($ssl_key == undef) {
      fail('nginx: SSL certificate/key (ssl_cert/ssl_cert) and/or SSL Private must be defined and exist on the target system(s)')
    } else {
      $ssl_dir = "${nginx::params::nx_conf_dir}/ssl"
      $ssl_cert_file = "${ssl_dir}/${server_name}.pem"
      $ssl_key_file = "${ssl_dir}/${server_name}.key"
      file {$ssl_dir:
        ensure => directory,
        owner => '0',
        group => '0',
        mode => '0755',
      }
      file {$ssl_cert_file:
        ensure  => file,
        content => $ssl_cert,
      }
      file {$ssl_key_file:
        ensure  => file,
        content => $ssl_key,
      }
    }
  }

  # Use the File Fragment Pattern to construct the configuration files.
  # Create the base configuration file reference.
  if ($listen_port != $ssl_port) {
    file { "${nginx::config::nx_temp_dir}/nginx.d/${name}-001":
      ensure  => $ensure ? {
        'absent' => absent,
        default  => 'file',
      },
      content => template('nginx/vhost/vhost_header.erb'),
      notify => Class['nginx::service'],
    }
  }
  
  if ($ssl == 'true') and ($ssl_port == $listen_port) {
    $ssl_only = 'true'
  }

  # Create the default location reference for the vHost
  nginx::resource::location {"${name}-default":
    ensure               => $ensure,
    vhost                => $name,
    ssl                  => $ssl,
    ssl_only             => $ssl_only,
    location             => '/',
    proxy                => $proxy,
    proxy_read_timeout   => $proxy_read_timeout,
    try_files            => $try_files,
    www_root             => $www_root,
    notify               => Class['nginx::service'],
  }

  # Support location_cfg_prepend and location_cfg_append on default location created by vhost
  if $location_cfg_prepend {
    Nginx::Resource::Location["${name}-default"] {
      location_cfg_prepend => $location_cfg_prepend
    }
  }
  if $location_cfg_append {
    Nginx::Resource::Location["${name}-default"] {
      location_cfg_append => $location_cfg_append
    }
  }
  # Create a proper file close stub.
  if ($listen_port != $ssl_port) {
    file {"${nginx::config::nx_temp_dir}/nginx.d/${name}-699":
      ensure  => $ensure ? {
        'absent' => absent,
        default  => 'file',
      },
      content => template('nginx/vhost/vhost_footer.erb'),
      notify  => Class['nginx::service'],
    }
  }

  # Create SSL File Stubs if SSL is enabled
  if ($ssl == 'true') {
    file {"${nginx::config::nx_temp_dir}/nginx.d/${name}-700-ssl":
      ensure => $ensure ? {
        'absent' => absent,
        default  => 'file',
      },
      content => template('nginx/vhost/vhost_ssl_header.erb'),
      notify => Class['nginx::service'],
    }
    file {"${nginx::config::nx_temp_dir}/nginx.d/${name}-999-ssl":
      ensure => $ensure ? {
        'absent' => absent,
        default  => 'file',
      },
      content => template('nginx/vhost/vhost_footer.erb'),
      notify => Class['nginx::service'],
    }
  }
}
