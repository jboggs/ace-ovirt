# -*- ruby -*-
# Rakefile: build appliance configuration engine rpms
#
# Copyright (C) 2007 Red Hat, Inc.
#
# Distributed under the GNU Lesser General Public License v2.1 or later.
# See COPYING for details
#
# Bryan Kearney <bkearney@redhat.com>

require 'rake/clean'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rake/packagetask'

ROOT_DIR = File::expand_path(".")
PKG_VERSION="0.0.94"
PACKAGE_DIR = ROOT_DIR + "/pkg"

#
# Files to clean up
#

CLEAN.include("**/*~","pkg")


# Packaging Tasks
#
Rake::PackageTask.new("ace-ovirt", PKG_VERSION) do |pkg|
    pkg.need_tar_gz = true
    pkg.package_files.include(Dir["ace-ovirt/**/*"])    
end 


#
# Tasks to build the rpms
#

# Set up the directories
task :rpm => [ :package ] do |t|
    Dir["*.spec"].each do |specfile|
        spec = File.basename(specfile)
        cp(specfile, "pkg")
        puts("Building with spec file #{spec}")        
        Dir::chdir("pkg") do |dir|
            dir = File::expand_path(".")
            system("rpmbuild --define '_topdir #{dir}' --define '_sourcedir #{dir}' --define '_srcrpmdir #{dir}' --define '_rpmdir #{dir}' --define '_builddir #{dir}' -ba #{spec} > #{spec}.rpmbuild.log 2>&1")
            if $? != 0
                raise "rpmbuild failed"
            end
        end
    end
end
