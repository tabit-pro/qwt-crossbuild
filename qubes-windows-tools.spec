
%define devbranch mingw
%define user marmarek

Name:		qubes-windows-tools
Version:	4.0
Release:	220
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
Source1:	https://codeload.github.com/marmarek/qubes-core-vchan-xen/zip/%{devbranch}#/qubes-core-vchan-xen-%{devbranch}.zip
Source2:	https://codeload.github.com/marmarek/qubes-core-agent-windows/zip/%{devbranch}#/qubes-core-agent-windows-%{devbranch}.zip
Source3:	https://codeload.github.com/marmarek/qubes-windows-utils/zip/%{devbranch}#/qubes-windows-utils-%{devbranch}.zip
Source4:	https://codeload.github.com/marmarek/qubes-core-qubesdb/zip/%{devbranch}#/qubes-core-qubesdb-%{devbranch}.zip
Source5:	https://codeload.github.com/marmarek/qubes-gui-common/zip/%{devbranch}#/qubes-gui-common-%{devbranch}.zip
Source6:	https://codeload.github.com/marmarek/qubes-gui-agent-windows/zip/%{devbranch}#/qubes-gui-agent-windows-%{devbranch}.zip
Source7:	https://codeload.github.com/marmarek/qubes-installer-qubes-os-windows-tools/zip/%{devbranch}#/qubes-installer-qubes-os-windows-tools-%{devbranch}.zip
Source8:	https://codeload.github.com/marmarek/qubes-vmm-xen-windows-pvdrivers/zip/%{devbranch}#/qubes-vmm-xen-windows-pvdrivers-%{devbranch}.zip
Source9:	https://codeload.github.com/marmarek/qubes-vmm-xen-win-pvdrivers-xeniface/zip/%{devbranch}#/qubes-vmm-xen-win-pvdrivers-xeniface-%{devbranch}.zip

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

patch0:         devcon-headers.patch

# remove confusing DriverEntry
#patch31:        qwt-gdi-fake-driverentry.patch

# remove CreateEvent from event processing loop
patch40:        qwt-gui-agent-cpu-usage.patch

# dirty
patch50:        qwt-xenvchan-test.patch
patch51:        qwt-vchan-test.patch

%prep
%setup -c
for i in $(ls %{_sourcedir}/qubes*.zip);
do unzip $i; done;
cat %{_sourcedir}/xen*.tar | tar -xvf - -i
cp -f %{S:100} %{S:14} %{S:15} %{S:16} %{S:17} %{S:18} %{S:19} ./
make prep
sed -i -e '/version.h/d' qubes-gui-agent-windows-mingw/include/version_common.rc

%autopatch -p1

%description
PV Drivers and Qubes Tools for Windows AppVMs.

%build

make x86
make x64

mkdir -p iso-content
cp qubes-tools-x86.msi iso-content/
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

