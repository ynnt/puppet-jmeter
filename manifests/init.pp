# == Class: jmeter
#
# This class installs the latest stable version of JMeter.
#
# === Examples
#
#   class { 'jmeter': }
#

class jmeter (
  $jmeter_version           = '2.13',
  $jmeter_install_base_dir  = '/usr/share',
  $jmeter_directory         = 'jmeter',
  $jmeter_plugins_install   = false,
  $jmeter_plugins_version   = '1.2.1',
  $jmeter_plugins_set       = ['Standard'],
  $java_version             = '7',
) {

  Exec { path => '/bin:/usr/bin:/usr/sbin' }

  if $java_version != 'None' {
    $jdk_pkg = $::osfamily ? {
      debian => "openjdk-${java_version}-jre-headless",
      redhat => "java-1.${java_version}.0-openjdk"
    }

  ensure_packages($jdk_pkg)
  }

  $jmeter_dependencies = [ 'wget', 'unzip' ]
  ensure_packages($jmeter_dependencies)

  exec { 'download-jmeter':
    command => "wget -P /root http://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${jmeter_version}.tgz",
    creates => "/root/apache-jmeter-${jmeter_version}.tgz",
    cwd     => "$jmeter_install_base_dir"
  }

  exec { 'install-jmeter':
    command => "tar xzf /root/apache-jmeter-${jmeter_version}.tgz && mv apache-jmeter-${jmeter_version} ${jmeter_dependencies}",
    cwd     => "$jmeter_install_base_dir",
    creates => "${jmeter_install_base_dir}/${jmeter_directory}",
    require => Exec['download-jmeter'],
  }

  if $jmeter_plugins_install == true {
    jmeter::plugins_install { $jmeter_plugins_set:
      plugins_version => $jmeter_plugins_version,
      jmeter_lib_path => "${jmeter_install_base_dir}/${jmeter_directory}/lib",
      require         => [Package['wget'], Package['unzip'], Exec['install-jmeter']],
    }
  }
}
