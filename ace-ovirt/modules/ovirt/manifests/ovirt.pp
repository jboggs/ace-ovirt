#--
#  Copyright (C) 2008 Red Hat Inc.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2.1 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
# Author: Joey Boggs <jboggs@redhat.com>
#--

class ovirt::setup {

        package {"ovirt-server":
		ensure => installed,
		require => Single_exec[set_pw_expiration]
	}

	package {"httpd":
	        ensure => installed;
	}
	
	package {"libvirt":
  	      ensure => installed;
	}

	package {"rubygem-rake":
		ensure => installed;
	}

	package {"qpidd":
	        ensure => installed;
	}

	package {"collectd":
		ensure => installed;
	}

	package {"ntp":
	        ensure => installed;
	}

	package {"ntpdate":
  	      ensure => installed;
        }

	file {"/etc/collectd.conf":
		source => "puppet:///ovirt/collectd.conf",
		notify => Service[collectd]
	}

	file {"/etc/qpidd.conf":
		source => "puppet:///ovirt/qpidd.conf",
		notify => Service[qpidd]
	}

	single_exec { "db_migrate" :
		cwd => "/usr/share/ovirt-server/",
		path => ["/bin"],
		command => "export RAILS_ENV='production' && /usr/bin/rake db:migrate",
		require => [File["/usr/share/ovirt-server/log"],Package[ovirt-server],Package[rubygem-rake]]
	}

	file { "/usr/share/ovirt-server/log" :
		ensure => directory,
		require => Package[ovirt-server]
	}

        single_exec { "create_ovirtadmin_acct" :
		command => "/usr/share/ovirt-server/script/grant_admin_privileges ovirtadmin",
		require => Single_Exec[db_migrate]
	}

	single_exec { "add_host" : 
		command => "/usr/bin/ovirt-add-host $fqdn /usr/share/ovirt-server/ovirt.keytab",
		require => Package[ovirt-server]
	}	
 
	service {"httpd" :
                enable => true,
                require => Package[httpd],
                ensure => running
        }

        service {"ovirt-host-browser" :
                enable => true,
		require => [Package[ovirt-server],Single_Exec[db_migrate]],
                ensure => running
        }
 
        service {"ovirt-host-status" :
                enable => true,
		require => [Package[ovirt-server],Single_Exec[db_migrate]],
                ensure => running
	}

        service {"ovirt-host-collect" :
                enable => true,
		require => [Package[ovirt-server],Single_Exec[db_migrate]],
                ensure => running
        }

        service {"ovirt-mongrel-rails" :
                enable => true,
		require => [Package[ovirt-server],Single_Exec[db_migrate]],
                ensure => running,
		notify => Service[httpd]
        }
 
	service {"ovirt-taskomatic" :
                enable => true,
		require => [Package[ovirt-server],Single_Exec[db_migrate]],
                ensure => running
        }

	service {"libvirtd" :
                enable => true,
		require => Package[libvirt],
		ensure => running
        }

        service {"qpidd" :
                enable => true,
                ensure => running,
                require => Package[qpidd]
                }

        service {"collectd" :
                enable => true,
                ensure => running,
                require => Package[collectd]
                }

	service {"ntpdate" :
		enable => true,
		ensure => running,
		require => Package[ntpdate]
		}

	service {"ntpd" :
                enable => true,
                ensure => running,
		require => Package[ntp]
                }

#	firewall_rule{"http": destination_port => "80"}

}
