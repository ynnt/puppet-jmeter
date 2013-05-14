# == Class: jmeter
#
# This class installs the latest stable version of JMeter.
#
# === Examples
#
#   class { 'jmeter': }
#
class jmeter(
  $jmeter_version = '2.9',
) {

  Exec { path => '/bin:/usr/bin:/usr/sbin' }

  $jdk_pkg = $::osfamily ? {
    debian => 'openjdk-6-jre-headless',
    redhat => 'java-1.6.0-openjdk'
  }

  package { $jdk_pkg:
    ensure => present,
  }

  package { 'unzip':
    ensure => present,
  }

  exec { 'download-jmeter':
    command => "wget -P /root http://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${jmeter_version}.tgz",
    creates => "/root/apache-jmeter-${jmeter_version}.tgz"
  }

  exec { 'install-jmeter':
    command => "tar xzf /root/apache-jmeter-${jmeter_version}.tgz && mv apache-jmeter-${jmeter_version} jmeter",
    cwd     => '/usr/share',
    creates => '/usr/share/jmeter',
    require => Exec['download-jmeter'],
  }

  exec { 'download-jmeter-plugins':
    command => 'wget -P /root http://jmeter-plugins.googlecode.com/files/JMeterPlugins-0.5.4.zip',
    creates => '/root/JMeterPlugins-0.5.4.zip'
  }

  exec { 'install-jmeter-plugins':
    command => 'unzip -q -d JMeterPlugins JMeterPlugins-0.5.4.zip && mv JMeterPlugins/JMeterPlugins.jar /usr/share/jmeter/lib/ext',
    cwd     => '/root',
    creates => '/usr/share/jmeter/lib/ext/JMeterPlugins.jar',
    require => [Package['unzip'], Exec['install-jmeter'], Exec['download-jmeter-plugins']],
  }
}
