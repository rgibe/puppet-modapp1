class modapp1::install inherits modapp1 {

  # Fix update with apt::update doesn't work
  exec { 'apt-update':
     command => "/usr/bin/apt-get update"
  }

  # List of Packages
  ##################

  $pkg_list = ['libapache2-mod-jk']
  package { $pkg_list:
    ensure => present,
    require  => Exec['apt-update'],
  }
 
  # Default install Tomcat from package
  #####################################

  tomcat::install { 'default':
    install_from_source => false,
    package_name => 'tomcat7',
    package_ensure => present,
  }

}
