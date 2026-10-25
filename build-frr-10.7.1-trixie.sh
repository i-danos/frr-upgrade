set -e
export DEBIAN_FRONTEND=noninteractive
echo "Acquire::Retries \"8\";" > /etc/apt/apt.conf.d/80retries; apt-get update -qq
apt-get install -y -qq --fix-missing build-essential dpkg-dev devscripts equivs fakeroot >/dev/null
cd /work
rm -rf src && mkdir src && cd src
cp ../frr_10.7.1-2.dsc ../frr_10.7.1-2.debian.tar.xz ../frr_10.7.1.orig.tar.xz .
dpkg-source -x frr_10.7.1-2.dsc frr-10.7.1 >/dev/null
cd frr-10.7.1
# trixie lacks lua5.5 and sphinx>=9; libyang's dev package is libyang3-dev here
sed -i 's/python3-sphinx:native (>= 9)/python3-sphinx:native/' debian/control
apt-cache show libyang-dev >/dev/null 2>&1 || sed -i 's/^ libyang-dev,/ libyang3-dev,/' debian/control
dch --force-bad-version -v 10.7.1-2~danos1 -D unstable "Rebuild for Debian 13 (trixie) without Lua; DANOS-Open 2608." >/dev/null 2>&1
export DEB_BUILD_PROFILES="pkg.frr.nolua nocheck"
export DEB_BUILD_OPTIONS="nocheck"
apt-get install -y -qq --no-install-recommends bison chrpath flex gawk install-info libc-ares-dev libcap-dev libcrypt-dev libelf-dev libjson-c-dev libpam0g-dev libpcre2-dev libprotobuf-c-dev libpython3-dev libreadline-dev librtr-dev libsnmp-dev libssh-dev libunwind-dev libyang-dev pkgconf protobuf-c-compiler python3-dev python3-pytest python3-sphinx python3 texinfo debhelper >/dev/null
dpkg-buildpackage -us -uc -b -d -Ppkg.frr.nolua,nocheck -j$(nproc) > /work/build.log 2>&1
echo BUILD_EXIT=$?
ls -la /work/src/*.deb
