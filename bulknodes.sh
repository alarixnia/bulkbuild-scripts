#!/bin/sh

base_path="/sandbox/nb9-amd64-trunk"
njobs=$(sysctl -n hw.ncpuonline)
machine_arch=$(uname -m)
processor_arch=$(uname -p)
os_release=$(uname -r)
tmpfs_base=0

umount_all() {
	for i in $(seq "$njobs");
	do
		printf "Destroying chroot %d..." "$i"
		umount "${base_path}/chroot/${i}/data/logs" 2>/dev/null
		umount "${base_path}/chroot/${i}/data/distfiles" 2>/dev/null
		umount "${base_path}/chroot/${i}/data/pbulk" 2>/dev/null
		umount "${base_path}/chroot/${i}/data/packages" 2>/dev/null
		umount "${base_path}/chroot/${i}/proc" 2>/dev/null
		umount "${base_path}/chroot/${i}/tmp" 2>/dev/null || \
		    umount -f "${base_path}/chroot/${i}/" 2>/dev/null
		umount "${base_path}/chroot/${i}/var/shm" 2>/dev/null
		umount "${base_path}/chroot/${i}/bin" 2>/dev/null
		umount "${base_path}/chroot/${i}/sbin" 2>/dev/null
		umount "${base_path}/chroot/${i}/lib" 2>/dev/null
		umount "${base_path}/chroot/${i}/libexec" 2>/dev/null
		umount "${base_path}/chroot/${i}/usr/bin" 2>/dev/null
		umount "${base_path}/chroot/${i}/usr/sbin" 2>/dev/null
		umount "${base_path}/chroot/${i}/usr/include" 2>/dev/null
		umount "${base_path}/chroot/${i}/usr/lib" 2>/dev/null
		umount "${base_path}/chroot/${i}/usr/libdata" 2>/dev/null
		umount "${base_path}/chroot/${i}/usr/libexec" 2>/dev/null
		umount "${base_path}/chroot/${i}/usr/pkgsrc" 2>/dev/null
		umount "${base_path}/chroot/${i}/usr/share" 2>/dev/null
		umount "${base_path}/chroot/${i}/usr/X11R7"
		umount "${base_path}/chroot/${i}/" 2>/dev/null || \
		    umount -f "${base_path}/chroot/${i}/" 2>/dev/null
	done
}

mount_all() {
	for i in $(seq "$njobs");
	do
		printf "Creating chroot %d..." "$i"
		mkdir -p "${base_path}/chroot/${i}/"
		mount_tmpfs none "${base_path}/chroot/${i}/"
		mkdir -p ${base_path}/chroot/${i}/data/logs
		mount_null "${base_path}/data/logs" "${base_path}/chroot/${i}/data/logs"
		mkdir -p ${base_path}/chroot/${i}/data/distfiles
		mount_null "${base_path}/data/distfiles" "${base_path}/chroot/${i}/data/distfiles"
		mkdir -p ${base_path}/chroot/${i}/data/pbulk
		mount_null "${base_path}/data/pbulk" "${base_path}/chroot/${i}/data/pbulk"
		mkdir -p ${base_path}/chroot/${i}/data/packages
		mount_null "${base_path}/data/packages" "${base_path}/chroot/${i}/data/packages"
		mkdir -p "${base_path}/chroot/${i}/proc"
		mount_procfs -o linux none "${base_path}/chroot/${i}/proc"
		mkdir -p "${base_path}/chroot/${i}/tmp"
		mount_tmpfs -m 1777 none "${base_path}/chroot/${i}/tmp"
		mkdir -p "${base_path}/chroot/${i}/var/shm"
		mount_tmpfs -m 1777 none "${base_path}/chroot/${i}/var/shm"
		mkdir -p "${base_path}/chroot/${i}/bin"
		mkdir -p "${base_path}/chroot/${i}/sbin"
		mkdir -p "${base_path}/chroot/${i}/lib"
		mkdir -p "${base_path}/chroot/${i}/libexec"
		mkdir -p "${base_path}/chroot/${i}/usr/bin"
		mkdir -p "${base_path}/chroot/${i}/usr/sbin"
		mkdir -p "${base_path}/chroot/${i}/usr/include"
		mkdir -p "${base_path}/chroot/${i}/usr/lib"
		mkdir -p "${base_path}/chroot/${i}/usr/libdata"
		mkdir -p "${base_path}/chroot/${i}/usr/libexec"
		mkdir -p "${base_path}/chroot/${i}/usr/share"
		mkdir -p "${base_path}/chroot/${i}/usr/X11R7"
		mkdir -p "${base_path}/chroot/${i}/usr/pkgsrc"
		mount_null -o ro "${base_path}/usr/pkgsrc" "${base_path}/chroot/${i}/usr/pkgsrc"
		if [ "$tmpfs_base" -ne 0 ]; then
			cp -a ${base_path}/bin/* "${base_path}/chroot/${i}/bin"
			cp -a ${base_path}/sbin/* "${base_path}/chroot/${i}/sbin"
			cp -a ${base_path}/lib/* "${base_path}/chroot/${i}/lib"
			cp -a ${base_path}/libexec/* "${base_path}/chroot/${i}/libexec"
			cp -a ${base_path}/usr/bin/* "${base_path}/chroot/${i}/usr/bin"
			cp -a ${base_path}/usr/sbin/* "${base_path}/chroot/${i}/usr/sbin"
			cp -a ${base_path}/usr/include/* "${base_path}/chroot/${i}/usr/include"
			cp -a ${base_path}/usr/lib/* "${base_path}/chroot/${i}/usr/lib"
			cp -a ${base_path}/usr/libdata/* "${base_path}/chroot/${i}/usr/libdata"
			cp -a ${base_path}/usr/libexec/* "${base_path}/chroot/${i}/usr/libexec"
			cp -a ${base_path}/usr/share/* "${base_path}/chroot/${i}/usr/share"
			cp -a ${base_path}/usr/X11R7/* "${base_path}/chroot/${i}/usr/X11R7"
		else
			mount_null -o ro "${base_path}/bin" "${base_path}/chroot/${i}/bin"
			mount_null -o ro "${base_path}/sbin" "${base_path}/chroot/${i}/sbin"
			# Lib directories are "rw" to allow compat80 etc
			# to be installed which is needed by some binary language
			# bootstraps
			mount_null -o rw "${base_path}/lib" "${base_path}/chroot/${i}/lib"
			mount_null -o ro "${base_path}/libexec" "${base_path}/chroot/${i}/libexec"
			mount_null -o ro "${base_path}/usr/bin" "${base_path}/chroot/${i}/usr/bin"
			mount_null -o ro "${base_path}/usr/sbin" "${base_path}/chroot/${i}/usr/sbin"
			mount_null -o ro "${base_path}/usr/include" "${base_path}/chroot/${i}/usr/include"
			mount_null -o rw "${base_path}/usr/lib" "${base_path}/chroot/${i}/usr/lib"
			mount_null -o ro "${base_path}/usr/libdata" "${base_path}/chroot/${i}/usr/libdata"
			mount_null -o ro "${base_path}/usr/libexec" "${base_path}/chroot/${i}/usr/libexec"
			mount_null -o ro "${base_path}/usr/share" "${base_path}/chroot/${i}/usr/share"
			mount_null -o ro "${base_path}/usr/X11R7" "${base_path}/chroot/${i}/usr/X11R7"
		fi
		mkdir -p "${base_path}/chroot/${i}/var/tmp"
		chmod 1777 "${base_path}/chroot/${i}/var/tmp"
		cp -a ${base_path}/var/* "${base_path}/chroot/${i}/var"
		mkdir -p "${base_path}/chroot/${i}/etc"
		cp -a ${base_path}/etc/* "${base_path}/chroot/${i}/etc"
		mkdir -p "${base_path}/chroot/${i}/dev"
		cp -a ${base_path}/dev/* "${base_path}/chroot/${i}/dev"
	done
}

init_pbulk() {
	mkdir -p ${base_path}/data/pbulk
	mkdir -p ${base_path}/data/logs/bulklog
	mkdir -p ${base_path}/data/logs/bulklog.old
	mkdir -p ${base_path}/data/packages
	mkdir -p ${base_path}/data/distfiles
	mkdir -p ${base_path}/var/tmp
	mkdir -p ${base_path}/tmp
	chmod 1777 ${base_path}/tmp
	mkdir -p ${base_path}/var/shm
	chmod 1777 ${base_path}/var/shm
	mkdir -p ${base_path}/var/tmp
	chmod 1777 ${base_path}/var/tmp
	if ! [ -f ${base_path}/data/mk.conf.fragment ];
	then
		cp mk.conf.fragment ${base_path}/data/mk.conf.fragment
	fi
	pbulk_nodes=""
	for i in $(seq "$njobs");
	do
		pbulk_nodes="${pbulk_nodes} /chroot/${i}"
	done
	chroot ${base_path} env \
		PBULKWORK=/tmp/work-pbulk \
		PBULKPREFIX=/data/pbulk \
		DISTDIR=/data/distfiles \
		PACKAGES=/data/packages \
		BULKLOG=/data/logs/bulklog \
		MAKE_JOBS=${njobs} \
		sh /usr/pkgsrc/mk/pbulk/pbulk.sh -n \
		-d "${pbulk_nodes}" -c /data/mk.conf.fragment
	chroot ${base_path} sh -c \
		"cd /usr/pkgsrc/pkgtools/libkver && \
		MAKE_JOBS=${njobs} \
		DISTDIR=/data/distfiles \
		PACKAGES=/data/packages \
		WRKOBJDIR=/tmp/work-pbulk \
		/data/pbulk/bin/bmake install CHECK_RELRO=no"
	rm -rf ${base_path}/tmp/work-pbulk
	echo Now edit pbulk.conf and make.conf.
}

run_postfix() {
	chroot ${base_path} \
		/etc/rc.d/postfix onestart
}

stop_postfix() {
	chroot ${base_path} \
		/etc/rc.d/postfix onestop
}

run_build() {
	chroot ${base_path} \
		/data/pbulk/sbin/kver ${kver_args} \
			/data/pbulk/bin/bulkbuild
}

rebuild() {
	chroot ${base_path} \
		/data/pbulk/sbin/kver ${kver_args} \
			/data/pbulk/bin/bulkbuild-rebuild $*
}

restart_build() {
	chroot ${base_path} \
		/data/pbulk/sbin/kver ${kver_args} \
			/data/pbulk/bin/bulkbuild-restart
}

usage() {
	printf "Usage: bulknodes.sh [-a processor_arch]"
	printf " [-m machine_arch] [-r os_release] "
	printf " [-j njobs] [-b base_path] [-t]\n"
	printf " mount, umount, init-pbulk,"
	printf " run-build, restart-build, rebuild,"
	printf " run-postfix, stop-postfix\n"
	exit 1
}

while getopts ta:m:r:p:j:b: f
do
	case "$f" in
	a)
		processor_arch=$OPTARG
		;;
	m)
		machine_arch=$OPTARG
		;;
	r)
		os_release=$OPTARG
		;;
	j)
		njobs=$OPTARG
		;;
	b)
		base_path=$OPTARG
		;;
	t)
		tmpfs_base=1
		;;
	\?)
		usage
		;;
	esac
done
shift $((OPTIND - 1))

printf 'Machine arch: %s\n' "${machine_arch}"
printf 'Processor arch: %s\n' "${processor_arch}"
printf 'OS release: %s\n' "${os_release}"
printf 'Parallel jobs: %s\n' "${njobs}"
printf 'Base chroot path: %s\n' "${base_path}"

kver_args="-m ${machine_arch} -p ${processor_arch} -r ${os_release}"

case "$1" in
mount)
	mount_all
	exit 0
	;;
umount)
	umount_all
	exit 0
	;;
init-pbulk)
	init_pbulk
	exit 0
	;;
run-build)
	run_build
	exit 0
	;;
restart-build)
	restart_build
	exit 0
	;;
run-postfix)
	run_postfix
	exit 0
	;;
stop-postfix)
	stop_postfix
	exit 0
	;;
rebuild)
	rebuild
	exit 0
	;;
esac

usage
