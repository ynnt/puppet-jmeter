define jmeter::plugins_install (
  $plugins_version,
  $plugins_set = $title,
  $jmeter_lib_path,
  )
{
  $base_download_url = 'http://jmeter-plugins.org/downloads/file/'
  $plugins_file_base = "JMeterPlugins-${plugins_set}-${plugins_version}"

  exec { "download-jmeter-plugins-${plugins_set}":
    command => "wget -P /root ${base_download_url}/${plugins_file_base}.zip",
    creates => "/root/${plugins_file_base}.zip"
  }

  exec { "install-jmeter-plugins-${plugins_set}":
    command => "unzip -q -o -d JMeterPlugins-${plugins_set} ${plugins_file_base}.zip && cp -r JMeterPlugins-${plugins_set}/lib/* ${jmeter_lib_path}",
    cwd     => '/root',
    creates => "${jmeter_lib_path}/ext/JMeterPlugins-${plugins_set}.jar",
    require => Exec["download-jmeter-plugins-${plugins_set}"],
  }
}
