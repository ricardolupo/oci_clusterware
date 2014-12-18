
# encoding: utf-8
#
# Cookbook Name:: oci_clusterware
# Recipe:: default
#
# Copyright (c) 2014 Oracle and/or its affiliates. All rights reserved.
# $Id:$
#
# default[:oci_clusterware][:app_dir] = '/u01/app'
# default[:oci_clusterware][:db_loc] = ''
# default[:oci_clusterware][:db_tar] = 'database.tar'
# default[:oci_clusterware][:db_rsp] = 'database.rsp'

default[:oci_clusterware][:rawdevs] = %w( )

# Grid Values
default[:oci_clusterware][:grid_loc] = ''
default[:oci_clusterware][:grid_tar] = 'grid.tar'
default[:oci_clusterware][:grid_rsp] = 'grid.rsp'
default[:oci_clusterware][:grid_d] = '/u01/app/oracle/product/11.2.0/grid'
default[:oci_clusterware][:grid_diskgroup] = 'DATA'

# db values
#default[:oci_clusterware][:dba_group] = 'oinstall'
#default[:oci_clusterware][:oper_group] = 'oinstall'
# default[:oci_clusterware][:oracle_home] = '/u01/app/oracle/product/11.2.0/dbhome_1'
# Grid is dependent on oracle base.



#default[:oci_clusterware][:starterdb] = ''
#default[:oci_clusterware][:startersid] = ''
#default[:oci_clusterware][:startermem] = ''

default[:oci_clusterware][:passwd_sys] = ''
default[:oci_clusterware][:passwd_system] = ''
default[:oci_clusterware][:passwd_sysman] = ''

# This should be empty so far
default[:oci_clusterware][:grid][:sys_asm_passwd] = ''


#default[:oci_clusterware][:starterdataloc] = '/u01/oracle/oradata'



# These also exist in oci_oracledb
#default[:oci_clusterware][:installs_dir] = '/u01/installs'
#default[:oci_clusterware][:oracle_base] = '/u01/app/oracle'
#default[:oci_clusterware][:inventory_loc] = '/u01/app/oraInventory'