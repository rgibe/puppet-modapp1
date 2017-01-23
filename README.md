#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Beginning with modapp1](#beginning-with-modapp1)
4. [Usage](#usage)
5. [Test and Development](#test-and-development)

## Overview

If you need to configure a service with: apache, modjk and tomcat
you may consider to use a "module like" this one.

Tested end developed on Debian/Ubuntu with Puppet 3 (also work with Puppet 4).

## Module Description

The basic idea of this project is to **provide a skeleton example and a way** to easy configure a service in an "atomic" and "self-contained" module.  

In this example I'm assuming that my "APP1 Service" uses:
apache, modjk, tomcat (ratio 1:1:1)

Mainly working on the define ```manifests/define/app1_instance.pp``` you should easily tune the desired features.

### Beginning with modapp1

By default, *just including* this module, you will get an "Hello World" javascript running inside a tomcat responding at the URL http://www.test1.dominio.it

The module accepts an "instance name parameter" so you can easily define your client URL.

=== Example:

*Manifest Syntax*  
~~~
class { 'modapp1':
  instance => 'client1'
}
~~~

*Hiera Syntax*

~~~
classes:
  - modapp1

modapp1::instance: 'client1'
~~~

You will get the service responding at http://www.client1.dominio.it

## Usage

As I said the "module core" is the define. One of the needs below this module is to **configure multiple instances** of the same "APP1 Service" by hiera.yaml file.

With the example below

~~~
classes:
  - modapp1

app1_instances:
  client1:
    jk_port: '10001'
    tomcat_port: '8001'
  client2:
    jk_port: '10002'
    tomcat_port: '8002'
~~~

you will get the following "APP1 Services":
* http://www.client1.dominio.it
* http://www.client2.dominio.it

Other define parameters:
* vh_port
* jk_port
* tomcat_port
* java_home

## Test and Development

You can test and work on this module also using my other project here:

https://github.com/rgibe/vagrant-puppet

As I mentioned this is a "skelethon/example"; you can easily tune the service configuration working on:
* manifests/config.pp
* manifests/define/app1_instance.pp

For example creating a "APP2 Service" who need 2 tomcat behind the apache VH or using different defines 
to manage the 3 components: apache, modjk, tomcat in an indipendent way (ratio X:Y:Z)
