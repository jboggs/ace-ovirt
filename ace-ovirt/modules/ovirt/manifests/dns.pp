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

define dns::bundled($mgmt_ipaddr="", $prov_ipaddr="") {

	package {"dnsmasq":
		ensure => installed,
		require => Single_exec["add_dns_server_to_resolv.conf"]
	}

	service {"dnsmasq" :
                ensure => running,
                enable => true,
		require => File["/etc/dnsmasq.d/ovirt-dns.conf"]
        }

        file {"/etc/dnsmasq.d/ovirt-dns.conf":
                content => template("ovirt/ovirt-dns.conf.erb"),
                mode => 644,
		notify => Service[dnsmasq],
		require => Package[dnsmasq]
        }

	single_exec {"add_dns_server_to_resolv.conf":
		command => "/bin/sed -e '1i nameserver $prov_ipaddr' -i /etc/resolv.conf",
		require => Single_exec["add_mgmt_server_to_etc_hosts"]
	}

	single_exec {"add_mgmt_server_to_etc_hosts":
		command => "/bin/echo $mgmt_ipaddr $ipa_host >> /etc/hosts",
		notify => Service[dnsmasq]
	}
}

class dns::remote {

#    On the pxe server you will need to ensure that the
#    next server option points to the ip address of the tftp server

# The following SRV records must be present in the dns server for everything
# to function properly. Replace example.com with the appropriate domain

#	_ovirt._tcp.example.com.    SRV 0 5 80 ovirtwuiserver.example.com.
#	_ipa._tcp.example.com.      SRV 0 5 80 ipaserver.example.com.
#	_ldap._tcp.example.com.     SRV 0 5 389 ldapserver.example.com.
#	_collectd._tcp.example.com. SRV 0 5 25826 ovirtwuiserver.example.com.
#	_qpidd._tcp.example.com.    SRV 0 5 5672 ovirtwuiserver.example.com.
#	_identify._tcp.example.com. SRV 0 5 12120 ovirtwuiserver.example.com.

# Also A records must be present for each oVirt node. Without this they are unable
# to determine their hostname and locate the management server.

}
