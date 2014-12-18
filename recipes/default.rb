# encoding: utf-8

# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved.
# $Id:$
#

# Cookbook Name:: oracle11gr2 (Oracle Database 11GR2)
# Attributes:: clusterware

# Trigger udev if udev rules change
execute 'triggerudev' do
  command 'udevadm trigger'
  action :nothing
end

# Raw disks get 1 partition. Create if needed
node[:oci_clusterware][:rawdevs].each do |dev|
  bash "fdisk_#{dev}" do
    user 'root'
    cwd '/tmp'
## Setup the partition
    code <<-EOF

      /sbin/fdisk /dev/#{dev} <<EOC
      n
      p
      1


      w
      EOC
    EOF
  not_if "/sbin/fdisk -l /dev/#{dev} | grep #{dev}1"
  end
end

# Make sure devices are created with the right permissions
template '/etc/udev/rules.d/99-raw.rules' do
  source 'etc/udev/rules.d/99-raw.rules.erb'
  variables(
    devices: node[:oci_clusterware][:rawdevs],
    user: 'oracle',
    group: 'oinstall'
  )
  notifies :run, 'execute[triggerudev]', :immediately
end

# Directory where we put installer files for use

instloc = "#{node[:oci_oracledb][:installs_dir]}"
srcloc = "#{node[:oci_clusterware][:grid_loc]}"
tarname = "#{node[:oci_clusterware][:grid_tar]}"

# Download/extract grid install
tarfile = "#{instloc}/#{node[:oci_clusterware][:grid_tar]}"

oci_common_manifest 'add Oracle Grid' do
  action :add_component
  component 'Oracle Grid' => '11.2.0.4.0'
  cookbook_name run_context.cookbook_collection[cookbook_name].metadata.name
  cookbook_version run_context.cookbook_collection[cookbook_name].metadata.version
end

# This is needed for other products to install with the same
# inventory location
template '/etc/oraInst.loc' do
  source 'etc/oraInst.loc.erb'
  variables(
	     invloc: node[:oci_oracledb][:inventory_loc] ,
	 )
end

remote_file tarfile do
  source "#{srcloc}/#{tarname}"
  backup false
end

execute 'extract_grid_install' do
  command "tar xf #{tarfile}"
  cwd {instloc
end

template "#{instloc}/grid.rsp" do
  # Get actual raw device names
  rawdevs = Array.new
  node[:oci_clusterware][:rawdevs].each_with_index do |dev, i|
    newi = i + 1
    rawdevs[i] = "/dev/raw/raw#{newi}"
  end
  variables(
    fqdn:  node['fqdn'],
    diskgroup: node[:oci_clusterware][:grid_diskgroup],
    asmpasswd:  node[:oci_clusterware][:grid][:sys_asm_passwd],
    devices: rawdevs,
    oraclebase: node[:oci_oracledb][:oracle_base],
    gridhome: node[:oci_clusterware][:grid_d],
  )
  source "#{instloc}/grid.rsp.erb"
end


template "#{instloc}/cfgrsp.properties" do
  variables(
    asmpasswd:  node[:oci_clusterware][:grid][:sys_asm_passwd],
  )
  source "#{instloc}/cfgrsp.properties.erb"
end

# Configure grid

gridcfgscript="#{node[:oci_clusterware][:grid_d]}/cfgtoollogs/configToolAllCommands"
execute 'gridConfigScript' do
  action :nothing
  user 'root'
  command "su -c '#{gridcfgscript} RESPONSE_FILE=#{instloc}/cfgrsp.properties' -l oracle"
end

gridrootsh = "#{node[:oci_clusterware][:grid_d]}/root.sh"
execute 'gridRootScript' do
  action :nothing
  user 'root'
  command "#{gridrootsh}"
  notifies :run, 'execute[gridConfigScript]', :immediately
end

execute 'invRootScript' do
  action :nothing
  user 'root'
  command "#{node[:oci_oracledb][:inventory_d]}/orainstRoot.sh"
end

bash 'install_grid' do
  user 'root'
  cwd "#{instloc}/grid"
  rspfile = "#{node[:oci_oracledb][:installs_dir]}/grid.rsp"
  code <<-EOF 
  su -c "#{instloc}/grid/runInstaller -silent -noconfig -responsefile #{rspfile}" -l oracle
  while [ "`ps aux | grep [o]racle.installer.oui`" != "" ]
  do
    sleep 1
  done
  EOF
  notifies :run, 'execute[gridRootScript]', :immediately
  not_if "test -x #{node[:oci_clusterware][:grid_d]}/root.sh"
end
