# == Class: modapp1
#
# Example of puppet module that will configure a service 
# with: apache, modjk, tomcat (1:1:1 ratio)
#
# I mean:
# 1 apache VH, 1 modjk worker, 1 tomcat
# 2 apache VH, 2 modjk worker, 2 tomcat
#
# === Parameters
#
# You can just provide the instance name.
# If no "instance name" is provided it will automatically 
# configure a default instance (see params.pp)
#
# === Examples
#
# Manifest Syntax  
# ===============
# class { 'modapp1':
#   instance => 'test1', # (optional)
# }
#
# Hiera Syntax
# ============
# classes:
#   - modapp1
#
# modapp1::instance: 'test1' # (optional)
#

class modapp1 (
  $instance  = undef,
) inherits modapp1::params {

  # Pick Parameter
  #################

  $_instance = pick($instance, $modapp1::params::instance)
  #notify { "${_instance}": }
  validate_string($_instance)

  # Supported OS
  ##############

  if ! ($::operatingsystem in [ 'Debian', 'Ubuntu' ]) {
    fail("Not Tested on: $::operatingsystem")
  }

  # Required Modules here
  #######################

  include apt
  # include tomcat # automatically included when used
  class { 'apache':
    default_vhost => false,
  }

  # Anchor this as per #8040 - this ensures that classes won't float off and
  # mess everything up.  You can read about this at:
  # http://docs.puppetlabs.com/puppet/2.7/reference/lang_containment.html#known-issues

  anchor { 'modapp1::begin': } ->
  class { '::modapp1::install': } ->
  class { '::modapp1::config': } ~>
  class { '::modapp1::service': } ->
  anchor { 'modapp1::end': }

}
