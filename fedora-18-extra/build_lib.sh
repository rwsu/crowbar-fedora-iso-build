#!/bin/bash
# This is sourced by build_crowbar.sh to enable it to stage Crowbar onto
# Fedora 18


# OS information for the OS we are building crowbar on to.
OS=fedora
OS_VERSION=18

# If we need to make a chroot to stage packages into, this is the minimal
# set of packages needed to bootstrap yum.  This package list has only been tested
# on Fedora 18

# Note filesystem should be the first package installed. It sets up the directory
# structure so that /bin, /lib, /lib64, and /sbin are links to directories
# user /usr. See http://fedoraproject.org/wiki/Features/UsrMove
OS_BASIC_PACKAGES=(filesystem audit-libs basesystem bash binutils \
    bzip2-libs chkconfig cracklib cracklib-dicts crontabs coreutils \
    device-mapper e2fsprogs e2fsprogs-libs elfutils-libelf ethtool expat \
    file-libs findutils gawk gdbm glib2 glibc glibc-common grep \
    info initscripts iputils keyutils-libs krb5-libs libacl libattr libcap \
    libcom_err libdb libffi libgcc libidn libselinux libsepol libstdc++ libsysfs libgcrypt \
    dbus-libs libcurl curl lua  libutempter libxml2 \
    libxml2-python logrotate m2crypto mlocate \
    module-init-tools ncurses ncurses-libs neon net-tools nss nss-sysinit \
    nss-softokn nss-softokn-freebl openldap openssl-libs libssh2 cyrus-sasl-lib nss-util \
    nspr openssl pam passwd libuser pcre popt psmisc python \
    python-libs python-pycurl python-iniparse python-urlgrabber readline rpm \
    rpm-libs rpm-python sed setup shadow-utils fedora-release \
    sqlite rsyslog tzdata xz xz-libs yum \
    yum-metadata-parser yum-utils zlib)

#
# See:
#   http://www.steve.org.uk/Software/rinse/
#   http://repository.steve.org.uk/cgi-bin/hgwebdir.cgi/rinse/file/964ec9650f08/etc

OS_REPO_POOL=""

# The name of the OS iso we are using as a base.
[[ $ISO ]] || ISO="Fedora-18-x86_64-DVD.iso"

# We always want to shrink the generated ISO, otherwise the install will
# fail due to lookingfor packages on the second ISO that we don't have.
SHRINK_ISO=true

# The location of OS packages on $ISO
find_cd_pool() ( echo "$IMAGE_DIR/Packages" )

# There is no public location to fetch the RHEL .iso from.  If you have one,
# you can change this function.
fetch_os_iso() {
    die "Cannot download download $ISO.  Please manually install it in $ISO_LIBRARY."
}

# Throw away packages we will not need on the iso
shrink_iso() {
    # Do nothing if we do not have a minimal-install set for this OS.
    [[ -f $CROWBAR_DIR/$OS_TOKEN-extra/minimal-install ]] || \
        return 0
    local pkgname pkgver
    while read pkgname pkgver; do
        INSTALLED_PKGS["$pkgname"]="$pkgver"
    done < "$CROWBAR_DIR/$OS_TOKEN-extra/minimal-install"
    mkdir -p "$BUILD_DIR/Packages"
    cp -a "$IMAGE_DIR/repodata" "$BUILD_DIR"
    make_chroot
    # Figure out what else we need for this build
    # that we did not get from the appropriate minimal-install.
    check_all_deps $(for bc in "${BARCLAMPS[@]}"; do
        echo ${BC_PKGS[$bc]}; done)
    for pkgname in "${!CD_POOL[@]}"; do
        [[ ${INSTALLED_PKGS["$pkgname"]} ]] || continue
        [[ -f ${CD_POOL["$pkgname"]} ]] || \
            die "Cannot stage $pkgname from the CD!"
        cp "${CD_POOL["$pkgname"]}" "$BUILD_DIR/Packages"

	# Reorganize packages for fedora ver > 17
        firstletter=$(echo $pkgname | awk '{print tolower(substr ($0, 0, 1))}')
        mkdir -p "$BUILD_DIR/Packages/$firstletter"
        cp "${CD_POOL["$pkgname"]}" "$BUILD_DIR/Packages/$firstletter"
    done
    sudo mount --bind "$BUILD_DIR" "$CHROOT/mnt"
    in_chroot 'cd /mnt; createrepo -g /mnt/repodata/3a27232698a261aa4022fd270797a3006aa8b8a346cbd6a31fae1466c724d098-c6-x86_64-comps.xml .'
    sudo umount -l "$CHROOT/mnt"
    sudo mount -t tmpfs -o size=1K tmpfs "$IMAGE_DIR/Packages"
    sudo mount -t tmpfs -o size=1K tmpfs "$IMAGE_DIR/repodata"
}

 . "$CROWBAR_DIR/redhat-common/build_lib.sh"
