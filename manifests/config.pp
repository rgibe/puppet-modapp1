class modapp1::config inherits modapp1 {

  apache::mod { 'jk': }
 
  file {
    '/etc/apache2/ssl':
      ensure => 'directory';
    '/etc/tomcat7/catalina.policy':
      ensure => link,
      force  => 'true',
      target => '/etc/tomcat7/policy.d/03catalina.policy';
    '/usr/share/tomcat7/conf':
      ensure => link,
      force  => 'true',
      target => '/etc/tomcat7';
  }

  # Create ModApp1 Instances
  ##########################

  $app1_instances = hiera_hash('app1_instances',[])
  if !empty($app1_instances) {
    create_resources('modapp1::define::app1_instance',$app1_instances)
  }
  else { modapp1::define::app1_instance { $_instance: } }

}
