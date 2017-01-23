define modapp1::define::app1_instance (
  $vh_port = 80,
  $jk_port = 10001,
  $tomcat_port = 8001,
  $java_home = '/usr/lib/jvm/java-7-openjdk-amd64/jre',
) {

  # If you need a class defined variable 
  # you can get it this way
  #notify { "Scope test $modapp1::_instance": }

  $service_url = "www.${name}.dominio.it"
  $hosts = [ 'localhost', 'remote' ]

  # Apache VH config
  ##################

  apache::vhost { "${service_url}":
    port    => $vh_port,
    docroot => "/var/www/${name}",
    rewrites => [
      {
        comment      => 'Redirect Base',
        rewrite_rule => ['^/$ /hello/hello.jsp [R,L]'],
      },
    ],
    jk_mounts => [
      {
        mount => '/hello',
        worker => "${name}",
      },
      {
        mount => '/hello/*',
        worker => "${name}",
      },
    ]  
  }

  # ModJK config
  ##############

  $lb_instance = "${name}"
  $worker_dir = '/etc/apache2/conf.d/'
  $worker_name = "${service_url}"
 
  file { "${worker_dir}${worker_name}.conf":
    content => template('modapp1/worker-lb.erb'),
    #content => template('modapp1/worker.erb'),
    owner   => root,
    group   => root,
    notify  => Service[apache2],
  }

  # Tomcat config
  ###############

  $service_name = "tomcat7-${name}"
  $catalina_home = '/usr/share/tomcat7'
  $catalina_base = "/opt/${service_name}"
  $instance_owner = 'tomcat7'
  $instance_group = 'tomcat7'

  $offset = regsubst($tomcat_port,'^\d+(\d{2})$','\1')
  #notify { "Get offset digits: ${offset}": }
  $http_port= '8080' + $offset
  $ajp_port= '10000' + $offset
  $jmx_port= '11000' + $offset

  $catalina_opts= "-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=${jmx_port} -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"

  file { 
    "/etc/init.d/${service_name}":
      content => template('modapp1/init-Debian.erb'),
      owner   => root,
      group   => root,
      mode => 0744;
    "${catalina_base}/bin/setenv.sh":
      content => template('modapp1/setenv.erb'),
      owner => $instance_owner,
      group => $instance_group,
      mode => 0744;
    "${catalina_base}/webapps/hello.war":
      source => 'puppet:///modules/modapp1/hello.war',
      owner => $instance_owner,
      group => $instance_group;
  }

  tomcat::instance { "${name}":
    catalina_home => $catalina_home,
    catalina_base => $catalina_base,
    manage_service => false, # managed later with "tomcat::service"
    user => $instance_owner,
    group => $instance_group,
    require => [
      File['/usr/share/tomcat7/conf'],
    ],
  }
  tomcat::config::server { "${name}-port":
    catalina_base => $catalina_base,
    port          => $tomcat_port,
  }
  tomcat::config::server::connector { "${name}-http-default":
    catalina_base => $catalina_base,
    port          => '8080',
    protocol      => 'HTTP/1.1',
    connector_ensure => 'absent',
    before        => "Tomcat::Service[${name}-service]",
  }
  tomcat::config::server::connector { "${name}-http":
    catalina_base => $catalina_base,
    port          => $http_port,
    protocol      => 'HTTP/1.1',
    before        => "Tomcat::Service[${name}-service]",
  }
  tomcat::config::server::connector { "${name}-ajp":
    catalina_base => $catalina_base,
    port          => $ajp_port,
    protocol      => 'AJP/1.3',
    before        => "Tomcat::Service[${name}-service]",
  }
  tomcat::service { "${name}-service":
    use_jsvc     => false,
    use_init     => true,
    service_name => $service_name,
    service_enable => true,
    service_ensure => running,
    subscribe => File["${catalina_base}/bin/setenv.sh"],
  }

  notify { "Try me at http://127.0.0.1:${http_port}/hello": }

}
