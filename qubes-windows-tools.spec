Name:		qubes-windows-tools
Version:	4.0
Release:	219
Summary:	Qubes Tools for Windows VMs
Group:		Qubes
License:	GPL
Obsoletes:	qubes-core-dom0-pvdrivers
BuildRequires:	genisoimage
BuildRequires:	mingw32-gcc mingw64-gcc
BuildRequires:	mingw32-winpthreads-static
BuildRequires:	mingw64-winpthreads-static
BuildRequires:	mingw32-gcc-c++ mingw64-gcc-c++
BuildRequires:	wine
BuildRequires:	svn
BuildArch:	noarch
# Retrieve devcon tool from windows samples
# svn export https://github.com/microsoft/Windows-driver-samples/trunk/setup/devcon | tar -czvf devcon.tar.gz devcon
Source0:	devcon.tar.gz
# Get the latest qwt source tree
# FIXME:
# It would be more appropriate to link releases 
# in corresponding github projects,
# so we could use /releases/latest api
Source1:	https://github.com/QubesOS/qubes-core-vchan-xen/archive/v4.0.5.tar.gz#/qubes-core-vchan-xen-4.0.5.tar.gz
Source2:	https://github.com/QubesOS/qubes-core-agent-windows/archive/v4.0.0.tar.gz#/qubes-core-agent-windows-4.0.0.tar.gz
Source3:	https://github.com/QubesOS/qubes-windows-utils/archive/v4.0.0.tar.gz#/qubes-windows-utils-4.0.0.tar.gz
Source4:	https://github.com/QubesOS/qubes-core-qubesdb/archive/v4.0.10.tar.gz#/qubes-core-qubesdb-4.0.10.tar.gz
Source5:	https://github.com/QubesOS/qubes-gui-common/archive/v4.0.2.tar.gz#/qubes-gui-common-4.0.2.tar.gz
Source6:	https://github.com/QubesOS/qubes-gui-agent-windows/archive/v4.0.0.tar.gz#/qubes-gui-agent-windows-4.0.0.tar.gz
Source7:	https://github.com/QubesOS/qubes-installer-qubes-os-windows-tools/archive/v4.0.1-3.tar.gz#/qubes-installer-qubes-os-windows-tools-4.0.1-3.tar.gz
Source8:	https://github.com/QubesOS/qubes-vmm-xen-windows-pvdrivers/archive/v4.0.0.tar.gz#/qubes-vmm-xen-windows-pvdrivers-4.0.0.tar.gz
Source9:	https://github.com/QubesOS/qubes-vmm-xen-win-pvdrivers-xeniface/archive/mm_ff24d3b2.tar.gz#/qubes-vmm-xen-win-pvdrivers-xeniface-mm_ff24d3b2.tar.gz

# Download unpackaged mingw headers
Source11:	https://raw.githubusercontent.com/Alexpux/mingw-w64/master/mingw-w64-headers/ddk/include/d3dnthal.h
Source12:	https://raw.githubusercontent.com/Alexpux/mingw-w64/master/mingw-w64-headers/ddk/include/ddrawint.h
Source13:	https://raw.githubusercontent.com/Alexpux/mingw-w64/master/mingw-w64-headers/ddk/include/dvp.h

# Add local sources
Source14:	videoprt.def
Source15:	win32k.def
Source16:	disable_svc.bat
Source17:	pkihelper.c
Source18:	qubes-tools.wxs
Source19:	diskpart.txt
Source100:	Makefile

# Download the latest stable xen binary drivers
Source21:	http://xenbits.xen.org/pvdrivers/win/8.2.2/xenbus.tar
Source22:	http://xenbits.xen.org/pvdrivers/win/8.2.2/xeniface.tar
Source23:	http://xenbits.xen.org/pvdrivers/win/8.2.2/xenvif.tar
Source24:	http://xenbits.xen.org/pvdrivers/win/8.2.2/xennet.tar
Source25:	http://xenbits.xen.org/pvdrivers/win/8.2.2/xenvbd.tar

### MinGW related bunch of patches
# decl - add missed, fix exist declarations
# variadic - use gnu compatible variadic macro
# headers - fix headers usage
patch0:         devcon-headers.patch
patch1:         qwt-device-helpers-decl-headers.patch
patch2:         qwt-file-receiver-define.patch
patch3:         qwt-gdi-decl-headers.patch
patch4:         qwt-libvchan-variadic-decl.patch
patch5:         qwt-libxenvchan-variadic-headers.patch
patch6:         qwt-miniport-headers.patch
patch7:         qwt-network-setup-headers.patch
patch8:         qwt-prepare-volume-decl-headers.patch
patch9:         qwt-version-common-headers.patch
patch10:        qwt-windows-utils-decl.patch
patch11:        qwt-xencontrol-headers.patch
patch12:        qwt-xencontrol-variadic.patch
Patch13:        qwt-gui-agent-decl.patch

# concat - implement string concatenation (have to be tested)
patch20:        qwt-gdi-concat.patch
patch21:        qwt-miniport-concat.patch
patch22:        qwt-relocate-dir-concat.patch

# remove non-portable try/except
patch30:       qwt-miniport-exception.patch

# remove confusing DriverEntry
patch31:        qwt-gdi-fake-driverentry.patch

# add manifest for file-sender executable
patch32:        qwt-file-sender-manifest.patch

###

# remove CreateEvent from event processing loop
patch40:        qwt-gui-agent-cpu-usage.patch

# dirty
patch50:        qwt-xenvchan-test.patch
patch51:        qwt-vchan-test.patch

%prep
%setup -c
for i in $(ls %{_sourcedir}/qubes*.tar.gz);
do tar -zxvf $i; done;
cat %{_sourcedir}/xen*.tar | tar -xvf - -i
cp -f %{S:100} %{S:14} %{S:15} %{S:16} %{S:17} %{S:18} %{S:19} ./
make prep
cp -f %{S:11} %{S:12} %{S:13} include/

%autopatch -p1

%description
PV Drivers and Qubes Tools for Windows AppVMs.

%build

#make x86
make x64

mkdir -p iso-content
#cp qubes-tools-x86.msi iso-content/
cp qubes-tools-x64.msi iso-content/
genisoimage -o qubes-windows-tools-%{version}.%{release}.iso -m .gitignore -JR iso-content

%install
mkdir -p $RPM_BUILD_ROOT/usr/lib/qubes/
cp qubes-windows-tools-%{version}.%{release}.iso $RPM_BUILD_ROOT/usr/lib/qubes/
ln -s qubes-windows-tools-%{version}.%{release}.iso $RPM_BUILD_ROOT/usr/lib/qubes/qubes-windows-tools.iso

%files
/usr/lib/qubes/qubes-windows-tools-%{version}.%{release}.iso
/usr/lib/qubes/qubes-windows-tools.iso

%changelog

