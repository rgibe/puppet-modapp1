class modapp1::service inherits modapp1 {

  # Disable tomcat "default" instance
  tomcat::service { 'default':
    use_jsvc     => false,
    use_init     => true,
    service_name => 'tomcat7',
    service_enable => false,
    service_ensure => stopped,
  }

}
