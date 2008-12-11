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

class dhcp::bundled { ($dhcp_start="", $dhcp_stop="", $dhcp_network="", $dhcp_domain="")


	package {"dnsmasq":
		ensure => installed,
		require => Single_exec["add_dns_server_to_resolv.conf"]
	}

	service {"dnsmasq" :
                ensure => running,
                enable => true,
		require => File["/etc/dnsmasq.d/ovirt-dhcp.conf"]
        }

        file {"/etc/dnsmasq.d/ovirt-dhcp.conf":
                content => template("ovirt/ovirt-dhcp.conf.erb"),
                mode => 644,
		notify => Service[dnsmasq],
		require => Package[dnsmasq]
        }

	single_exec {"dns_entries":
                command => "/usr/share/ace/modules/ovirt/files/dns_entries.sh $dhcp_start $dhcp_stop $dhcp_network $dhcp_domain",
		require => Single_exec["add_dns_server_to_etc_hosts"]
	}

}
