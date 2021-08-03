pkgsrc bulk build scripts
=========================

These are scripts to automate the use of pbulk (pkgsrc's parallel
bulk building tool) across multiple chroots on the same machine.

It supports non-native chroots, so you can e.g. build i386 packages
on an amd64 host, or build 8.0 packages on a 9.0 machine. libkver is
used to fake the kernel version number.

Using multiple chroots is recommended on multi-core systems to
properly parallelize the building of packages.

Usage
-----

- `mksandbox.sh` - download and extract NetBSD to a base chroot
- `bulknodes.sh` - manage parallel building nodes

Once the base chroot is created, use mount_null to install
pkgsrc to its /usr/pkg.

pbulk must be initialized in the base chroot with
`bulknodes.sh init-pbulk`.  Afterwards the worker chroots can be
mounted with `bulknodes.sh mount` and the build started with
`buildnodes.sh `bulknodes.sh run-build`.

After initialization you may want to edit
`${base_chroot}/data/pbulk/etc/pbulk.conf` to enable e.g.
publishing.

Ideas for later
---------------

tmpfs is faster than nullfs, so it may make sense to have
the NetBSD base system on tmpfs rather than nullfs mounts
within the parallel chroots.  However, I'm already limited
by memory building packages on tmpfs with 16 chroots,
especially when the bulk build reaches Firefox.
