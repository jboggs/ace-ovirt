ldapmodify -h management.priv.ovirt.org -p 389 -Y GSSAPI <<LDAP
dn: cn=ipaConfig,cn=etc,dc=priv,dc=ovirt,dc=org
changetype: modify
replace: ipaMaxUsernameLength
ipaMaxUsernameLength: 12
LDAP
