node default {

  user { 'bob':
    ensure => present,
  }

  git::repository { 'my repository':
    remote     => 'file:///tmp/remote',
    directory  => '/tmp/repository',
    revision    => 'tag2',
    user       => 'bob',
  }

}
