#!/bin/sh

base_path="/sandbox/nb9-amd64-trunk"
netbsd_url="https://cdn.NetBSD.org/pub/NetBSD/NetBSD-9.2/amd64/binary/sets"
netbsd_sets="base comp etc man misc text xbase xcomp xetc xfont xserver"
extract_suffix=

usage() {
	printf "usage: mksandbox-netbsd.sh [-b base_path]\n"
	printf " [-u netbsd_url] [-s extract_suffix]\n"
	exit 1
}

while getopts b:u:s: f
do
	case "$f" in
	b)
		base_path=$OPTARG
		;;
	u)
		netbsd_url=$OPTARG
		;;
	s)
		extract_suffix=$OPTARG
		;;
	\?)
		usage
		;;
	esac
done

if ! [ -n "${extract_suffix}" ];
then
	if printf '%s' "$netbsd_url" | grep -q amd64; then
		extract_suffix=".tar.xz"
	elif printf '%s' "$netbsd_url" | grep -q aarch64; then
		extract_suffix=".tar.xz"
	elif printf '%s' "$netbsd_url" | grep -q sparc64; then
		extract_suffix=".tar.xz"
	fi
fi

if ! [ -n "${extract_suffix}" ];
then
	extract_suffix=".tgz"
fi

mkdir -p "${base_path}/sets"

for set in ${netbsd_sets};
do
	if ! [ -f "${base_path}/sets/${set}${extract_suffix}" ];
	then
		ftp -o "${base_path}/sets/${set}${extract_suffix}" \
			"${netbsd_url}/${set}${extract_suffix}"
	fi
	echo "Extracting ${set}..."
	tar -C "$base_path" -xpf "${base_path}/sets/${set}${extract_suffix}"
done

echo "Creating /dev..."
chroot "${base_path}" sh -c "cd /dev && sh MAKEDEV all"

echo "Copying resolv.conf..."
cp /etc/resolv.conf ${base_path}/etc/resolv.conf
