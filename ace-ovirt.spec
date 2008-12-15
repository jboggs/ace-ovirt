%define ruby_sitelibdir %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define	pbuild 			%{_builddir}/%{name}-%{version}
%define binFile 		%{_bindir}/ace
%define initFile 		%{_initrddir}/ace
%define acehome  		%{_datadir}/ace
%define modulehome		%{acehome}/modules

Summary: 			ACE oVirt Module
Name: 				ace-ovirt
Version: 			0.0.94
Release: 			4%{?dist}
Group: 				Applications/Internet
License: 			LGPLv2+
BuildArch:                      noarch
URL: 				http://www.ovirt.org
Source0: 			%{name}-%{version}.tar.gz
BuildRoot: 			%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:	ruby(abi) = 1.8
Requires: 	ace
Requires: 	ace-postgres
Requires:       hal

%description
oVirt ACE module

%files
%defattr(-,root,root,-)
%{modulehome}/ovirt/*
%doc %{modulehome}/ovirt/COPYING



###########################
# Prep, Build, and Install
###########################
%prep
%setup -q

%build

%install
rm -rf %{buildroot}
install -d %{buildroot}/%{acehome}
install -d %{buildroot}/%{ruby_sitelibdir}
install -d %{buildroot}/%{_bindir}
install -d %{buildroot}/%{_initrddir}
cp -pr %{pbuild}/modules %{buildroot}/%{acehome}




%clean
rm -rf %{buildroot}

