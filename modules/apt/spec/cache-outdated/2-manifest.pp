node default {

  class { 'apt::update':
    max_cache_age => 50,
  }

}
