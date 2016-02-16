#!/bin/bash

#
# Citrix XenServer 5.5+ VM Backup Script
# This script provides online backup for Citrix Xenserver 5.5+ virtual machines
#
# @version	2016.001
# @created	2009-11-24
# @lastupdated	2016-02-16
#
# @originalauthor	Andy Burton
# @originalurl		http://www.andy-burton.co.uk/blog/
# @originalemail	andy@andy-burton.co.uk
#
# @author	David J. Pryke
# @url		https://david.pryke.us/xen-vm-backup
# @email	david@pryke.us
#

# Get current directory
dir=`dirname $0`

# Load functions and config
. $dir"/vm_backup.lib"
. $dir"/vm_backup.cfg"


# Create the temporary file for the backup summary email message
begin_tmp_summary_msg


# Begin logging (make sure "begin_tmp_summary_msg" is called before this)
log_enable


# Verify good remote mount (don't fill up local drives! Fail if remote mount unavailable)
remount_remote_backup_location


# Pre-backup cleanup
delete_old_backup_files


# Backup the pool database/metadata
backup_pool_database


# Backup all Xen hosts in the pool
backup_pool_hosts


# Switch backup_vms to set the VM uuids we are backing up in vm_backup_list
case $backup_vms in

	"all")
		if [ $vm_log_enabled ]; then
			log_message "Backup All VMs"
		fi
		set_all_vms
		;;	

	"running")
		if [ $vm_log_enabled ]; then
			log_message "Backup running VMs"
		fi
		set_running_vms
		;;

	"list")
		if [ $vm_log_enabled ]; then
			log_message "Backup list VMs (see vm_backup.cfg for list)"
		fi
		;;

	*)
		if [ $vm_log_enabled ]; then
			log_message "Backup no VMs"
		fi
		reset_backup_list
		;;

esac


# Backup VMs
backup_vm_list


# Send backup summary email
send_summary_email


# End
if [ $vm_log_enabled ]; then
	log_disable
fi
