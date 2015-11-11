define janus::deps::plugin::install(
  $janus_version = 'b5865bdd56569ae660bf945323705010ae55d7fc',
) {

  require 'build::autoconf'
  include 'janus'

  helper::script { "install janus plugin ${name}":
    content => template("${module_name}/plugin_install.sh"),
    unless  => "ls /opt/janus/lib/janus/plugins/libjanus_${name}.so",
    timeout => 900,
    require => Helper::Script['install janus'],
  }
}
