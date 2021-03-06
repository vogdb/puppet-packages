class vim {

  require 'apt'

  file { '/etc/vim':
    ensure => directory,
    owner  => '0',
    group  => '0',
    mode   => '0755',
  }

  file { '/etc/vim/vimrc.local':
    ensure  => file,
    content => template("${module_name}/vimrc"),
    owner   => '0',
    group   => '0',
    mode    => '0644',
  }

  package { 'vim':
    ensure   => present,
    provider => 'apt',
  }
}
