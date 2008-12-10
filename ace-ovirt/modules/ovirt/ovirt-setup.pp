import "firewall"
import "ovirt"

firewall::setup{"setup": status => "disabled"}  # disabling for first cut, firewall ordering shutting down ssh connection, will fix
#firewall_rule {"ssh": destination_port => '22'}

# FreeIPA config #
$realm_name = "PRIV.OVIRT.ORG"
$dm_password = "password"
$master_password = "password"
$admin_password = "password"
$password = "password"
$ldap_dn ="cn=ipaConfig,cn=etc,dc=priv,dc=ovirt,dc=org"

# Postgres configuration #
$db_username = "ovirt"    ### This is hardcoded currently, do not change
$db_password = "password"

# dns configuration #
$dhcp_interface = "eth2"
$dhcp_network = "192.168.50"
$dhcp_start = "3"
$dhcp_stop = "100"
$dhcp_domain = "priv.ovirt.org"
$ovirt_host = "management.priv.ovirt.org"
$ipa_host = "management.priv.ovirt.org"
$management_network_gateway = "192.168.50.2"
$ntp_server = "192.168.50.2"
$management_dns_server = "192.168.50.2"

# cobbler configuration
$cobbler_hostname #if remote
$cobbler_user_name="cobbler"
$cobbler_user_password="cobbler"

include dns::bundled
include postgres::bundled
include cobbler::bundled
include freeipa::bundled
include ovirt::setup


