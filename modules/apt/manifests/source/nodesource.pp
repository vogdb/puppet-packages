class apt::source::nodesource {

  apt::source { 'nodesource':
    entries => [
      "deb https://deb.nodesource.com/node_0.12 ${::lsbdistcodename} main",
      "deb-src https://deb.nodesource.com/node_0.12 ${::lsbdistcodename} main",
    ],
    keys    => {
      'nodesource' => {
        key     => '68576280',
        key_url => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key',
      }
    }
  }
}
