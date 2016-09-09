# == Class: jmeter::server
#
# This class configures the server component of JMeter.
#
# === Examples
#
#   class { 'jmeter::server': }
#
class jmeter::server($server_ip = '0.0.0.0') {
  include jmeter

  $jmeter_install_base_dir = $jmeter::jmeter_install_base_dir
  $jmeter_directory        = $jmeter::jmeter_directory

  $init_template = $::osfamily ? {
    debian => 'jmeter/jmeter-init.erb',
    redhat => 'jmeter/jmeter-init.redhat.erb'
  }

  file { '/etc/init.d/jmeter':
    content => template($init_template),
    owner   => root,
    group   => root,
    mode    => '0755',
  }

  if $::osfamily == 'debian' {
    exec { 'jmeter-update-rc':
      command     => '/usr/sbin/update-rc.d jmeter defaults',
      subscribe   => File['/etc/init.d/jmeter'],
      refreshonly => true,
    }
  }

  if $jmeter::jmeter_plugins_install == true {
    $jmeter_subscribe = [File['/etc/init.d/jmeter'], Jmeter::Plugins_install[$jmeter::jmeter_plugins_set]]
  }
  else {
    $jmeter_subscribe = [File['/etc/init.d/jmeter']]
  }

  service { 'jmeter':
    ensure    => running,
    enable    => true,
    require   => File['/etc/init.d/jmeter'],
    subscribe => $jmeter_subscribe,
  }
}
