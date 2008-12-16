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

import "postgres"
import "appliance_base/single_exec.pp"

class postgres::bundled{

        
	package {"postgresql-server":
                ensure => installed,
        }
        package {"ace-postgres":
		ensure => installed,
		require => Package[postgresql-server]
        }

	single_exec {"initialize_db":
		command => "/sbin/service postgresql initdb",
		creates => "/var/lib/pgsql/data/pg_hba.conf",
		require => Package[postgresql-server]
	}
        
        service {"postgresql" :
		ensure => running,
		enable => true,
		require => Single_exec[initialize_db]
        }

        single_exec {"create_ovirt_db":
		command => "/usr/bin/createdb ovirt",
		require => [Exec[postgres_add_all_trust], Service[postgresql]],
		user => "postgres"
        }

	single_exec {"create_ovirt_development_db":
                command => "/usr/bin/createdb ovirt_development",
                require => [Exec[postgres_add_all_trust], Service[postgresql]],
                user => "postgres"
        }

	postgres_execute_command {"ovirt_db_create_role":
		cmd => "CREATE ROLE ovirt LOGIN PASSWORD '$db_password' NOINHERIT VALID UNTIL 'infinity'", 
		database => "ovirt",
                require => Single_Exec[create_ovirt_db]
        }

	postgres_execute_command {"ovirt_db_grant_permissions":
		cmd => "GRANT ALL ON DATABASE ovirt TO ovirt;", 
		database => "ovirt",
                require => Postgres_execute_command[ovirt_db_create_role]                
        }

	exec {"postgres_add_all_trust":
                command => "/bin/echo 'local all all trust' > /var/lib/pgsql/data/pg_hba.conf",
		require => Single_exec[initialize_db],
		notify => Service[postgresql]
        }      

	exec {"postgres_add_localhost_trust":
		command => "/bin/echo 'host all all 127.0.0.1 255.255.255.0 trust' >> /var/lib/pgsql/data/pg_hba.conf",
		require => Exec[postgres_add_all_trust],
                notify => Service[postgresql]
        } 

	file { "/etc/ovirt-server/" :
                ensure => directory,
                require => Exec[postgres_add_localhost_trust]
        }

        file { "/etc/ovirt-server/db/" :
                ensure => directory,
                require => File["/etc/ovirt-server"]
        }

	exec {"touch_dbaccess_file": 
		command => "/bin/touch /etc/ovirt-server/db/dbaccess",
		require => File["/etc/ovirt-server/db"]
	}

	file_append {"db_password_file":
                file    => "/etc/ovirt-server/db/dbaccess",
		line    => "$db_password",
		require => Exec[touch_dbaccess_file]
        }     
	exec {"db_exists_file":
		command => "/bin/touch /etc/ovirt-server/db/exists",
		require => File_append[db_password_file]
	}
}

class postgres::remote{

# oVirt is not configured at this time to support a remote postgres connection

}

