#!/bin/bash

set -ex

cd $(dirname $0)
script_root="$(pwd)"

source util.sh
source config.sh

readonly DISABLED="TRUE"

function process_args() {
	for opt in "$@" ; do
		echo opt is: $opt

		if [ "${opt_full_install}" = "$opt" ] ; then
			readonly is_pre_chroot_install="TRUE"
			readonly call_post_chroot_install="TRUE"
			continue
		fi

		if [ "${opt_chroot}" = "$opt" ] ; then
			readonly call_post_chroot_install="TRUE"
			continue
		fi

		if [ "${opt_post_chroot}" = "$opt" ] ; then
			readonly is_post_chroot_install="TRUE"
			continue
		fi

		if [ "${opt_pre_chroot}" = "$opt" ] ; then
			readonly is_pre_chroot_install="TRUE"
			continue
		fi

		error_exit "Unknown program argument: $opt"
	done

	if [ "TRUE" = "${is_pre_chroot_install}" -a "TRUE" = "${is_post_chroot_install}" ] ; then
		error_exit "Please choose either --pre-chroot or --post-chroot as program argument. Not both."
	fi
}

function presetup() {
	if [ "TRUE" != "${DISABLED}" ] ; then
		# Was not able to connect to sks-keyservers.net
		gpg --keyserver hkps://hkps.pool.sks-keyservers.net --recv-keys 0xBB572E0E2D182910
	fi
	wget -O- https://gentoo.org/.well-known/openpgpkey/hu/wtktzo4gyuhzu8a4z5fdj3fgmr1u6tob?l=releng | gpg --import
}

function setup_date_and_time() {
	print_header "SETTING DATE AND TIME"
	if [ "TRUE" != "${DISABLED}" ] ; then
		emerge net-misc/ntp
		ntpd -q -g # TODO test that works. Time may be correct out of the box
	fi
}

# TODO run the setup all the way from beginning and test if this still works
function maybe_mount_partitions() {
	print_header "MOUNTING PARTITIONS"

	if [ "TRUE" != "$(is_mounted "${mountpoint_root}")" ] ; then
		mount ${root_partition_dev} ${mountpoint_root}
	fi

	if [ ! -d "${mountpoint_root}/boot" ] ; then
		mkdir ${mountpoint_root}/boot
	fi

	if [ "TRUE" != "$(is_mounted "${mountpoint_root}/boot")" ] ; then
		mount ${boot_partition_dev} ${mountpoint_root}/boot
	fi

	if [ ! -d "${mountpoint_root}/home" ] ; then
		mkdir ${mountpoint_root}/home
	fi

	if [ "TRUE" != "$(is_mounted "${mountpoint_root}/home")" ] ; then
		mount ${home_partition_dev} ${mountpoint_root}/home
	fi

	if [ "TRUE" != "$(is_mounted "${mountpoint_root}/proc")" ] ; then
		mount --types proc /proc ${mountpoint_root}/proc
	fi

	if [ "TRUE" != "$(is_mounted "${mountpoint_root}/sys")" ] ; then
		mount --rbind /sys ${mountpoint_root}/sys
		mount --make-rslave ${mountpoint_root}/sys
	fi

	if [ "TRUE" != "$(is_mounted "${mountpoint_root}/dev")" ] ; then
		mount --rbind /dev ${mountpoint_root}/dev
		mount --make-rslave ${mountpoint_root}/dev
	fi
}

function setup_partitions() {
	print_header "PARTITIONING"

	# TODO target machine has UEFI, will need to use GPT
	# Is it possible to use sfdisk or is there another similar tool?
	sfdisk --wipe always ${main_block_device} < ${saved_partition_table}
	mkswap ${swap_partition_dev}
	swapon ${swap_partition_dev}

	pvcreate ${lvm_partition_dev}
	vgcreate ${volgroup_name} ${lvm_partition_dev}

	lvcreate --yes --type linear -L ${root_size} -n root ${volgroup_name}
	lvcreate --yes --type linear -L ${home_size} -n home ${volgroup_name}

	mkfs.ext2 -F -F ${boot_partition_dev}
	mkfs.ext4 -F -F ${root_partition_dev}
	mkfs.ext4 -F -F ${home_partition_dev}

	maybe_mount_partitions
}

function setup_stage_tarball() {
	print_header "INSTALLING STAGE TARBALL"
	pushd ${mountpoint_root}

	wget ${frozen_stage3_release_dir}/${stage3_tar}
	wget ${frozen_stage3_release_dir}/${stage3_tar}.DIGESTS.asc # Contains info of .DIGESTS
	if [ "TRUE" != "${DISABLED}" ] ; then
		openssl dgst -r -sha512 ${stage3_tarball_filename} # TODO exit with error message if does not match
	fi

	# From Gentoo wiki:
	# To be absolutely certain that everything is valid, verify the
	# fingerprint shown with the fingerprint on the Gentoo signatures page.
	# Gentoo signatures page: https://www.gentoo.org/downloads/signatures/
	readonly gpg_match="Good signature from \"Gentoo Linux Release Engineering"
	gpg --verify ${stage3_tar}.DIGESTS.asc 2>&1 | grep "${gpg_match}"

	readonly signed_sum="$(grep -A1 SHA512 ${stage3_tar}.DIGESTS.asc | head -2 | grep -v SHA512)"
	readonly calculated_sum="$(sha512sum ${stage3_tar})"
	if [ "${signed_sum}" != "${calculated_sum}" ] ; then
		error_exit "Stage 3 tar sums do not match."
	fi

	tar xpvf ${stage3_tar} --xattrs-include='*.*' --numeric-owner
	popd
}

function setup_portage_configuration() {
	print_header "SETTING UP PORTAGE CONFIGURATION"

	cp ${make_conf} ${mountpoint_root}/etc/portage/make.conf
	mkdir --parents ${mountpoint_root}/etc/portage/repos.conf
	cp \
		${mountpoint_root}/usr/share/portage/config/repos.conf \
		${mountpoint_root}/etc/portage/repos.conf/gentoo.conf
	cp --dereference /etc/resolv.conf ${mountpoint_root}/etc/
}

function setup_portage() {
	emerge-webrsync

	eselect profile set default/linux/amd64/17.1

	emerge --verbose --update --deep --newuse @world

	# TODO Check if necessary to update make.conf. Was it changed during
	# portage setup?

	# TODO configure ACCEPT_LICENSE
	# to make.conf:
	# ACCEPT_LICENSE="-* @FREE"
	# Per package overrides are also possible. For example can change:
	# /etc/portage/package.license/kernel
}

function setup_timezone() {
	cp ${gentoo_config}/timezone /etc/timezone
	emerge --config sys-libs/timezone-data
}

function setup_locale() {
	cp ${gentoo_config}/locale.gen /etc/locale.gen
	locale-gen
	eselect locale set en_US
	env-update
	source /etc/profile
}

function setup_kernel() {
	emerge sys-kernel/gentoo-sources
	cp ${gentoo_config}/.config ${kernel_sources_dir}

	pushd ${kernel_sources_dir}
	make
	make modules_install
	make install
	popd

	emerge --ask sys-kernel/linux-firmware
}

function setup_initramfs() {
	# TODO
	# LVM initramfs support
	# 	* use ldd to verify that binary is static
	# 	* store /usr/src/initramfs/init configuration to ${gentoo_config}
	#		* see: https://wiki.gentoo.org/wiki/Custom_Initramfs#LVM

	# TODO install sys-fs/lvm2 with "static" USE flag
	USE="static static-libs" emerge sys-fs/lvm2

	# First install is expected to fail. License changes were required
	# before emerging.
	emerge --autounmask-write sys-kernel/genkernel || true
	# TODO check that configuration updates are actually license updates.
	etc-update --automode -3 # Merge license changes
	emerge sys-kernel/genkernel

	# TODO configuration

	# TODO is --install required?
	# genkernel --lvm initramfs
	genkernel --lvm --install initramfs

	rc-update add lvm boot

	# TODO LVM to kernel commandline. Do this in bootloader setup?
	#
	# /etc/default/grub
	# GRUB_CMDLINE_LINUX="dolvm"
}

function install_pre_chroot() {
	print_header "INSTALL_PRE-CHROOT"
	presetup
	setup_partitions
	setup_date_and_time
	setup_stage_tarball
	setup_portage_configuration
}

function install_chroot() {
	print_header "INSTALL_CHROOT"

	mkdir -p ${mountpoint_root}/${script_root}/
	cp -r ${script_root}/* ${mountpoint_root}/${script_root}/
	chroot ${mountpoint_root} /bin/bash -c \
		"${script_root}/install_gentoo.sh --post-chroot"
}

function install_post_chroot() {
	print_header "INSTALL_POST-CHROOT"

	source /etc/profile

	# TODO use an array to select setup functions to call
	test "$(should_setup_portage)" && setup_portage
	test "$(should_setup_timezone)" && setup_timezone
	test "$(should_setup_locale)" && setup_locale
	test "$(should_setup_kernel)" && setup_kernel
	test "$(should_setup_initramfs)" && setup_initramfs
}

function main() {
	process_args "$@"

	if [ "TRUE" = "${is_pre_chroot_install}" ] ; then
		install_pre_chroot
	fi

	if [ "TRUE" = "${call_post_chroot_install}" ] ; then
		maybe_mount_partitions
		install_chroot
	fi

	if [ "TRUE" = "${is_post_chroot_install}" ] ; then
		install_post_chroot
	fi
}

main "$@"
