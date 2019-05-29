FROM fedora-minimal:28

RUN microdnf install -y mingw32-gcc mingw64-gcc \
    mono-core osslsigncode libfaketime \
    mingw32-winpthreads-static \
    mingw64-winpthreads-static \
    mingw32-gcc-c++ mingw64-gcc-c++ \
    tar unzip make curl vim-enhanced \
    wine genisoimage patch git \
    file rpm-build createrepo 

RUN mkdir -p build,downloads
WORKDIR downloads

ENV WINEDEBUG=-all WINEARCH=win32 WINEPREFIX=/opt/wine/
RUN curl -s -LJ https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks > \
    /usr/local/bin/winetricks && chmod +x /usr/local/bin/winetricks
RUN winetricks --unattended dotnet40

# Retrieve devcon tool from windows samples 
RUN git clone https://github.com/microsoft/Windows-driver-samples

# Get the latest qwt source tree
# FIXME: 
# It would be more appropriate to link releases 
# in corresponding github projects,
# so we could use /releases/latest api
RUN curl -s -LJ --remote-name-all -C - \
    https://github.com/QubesOS/qubes-core-vchan-xen/archive/v4.0.5.tar.gz \
    https://github.com/QubesOS/qubes-core-agent-windows/archive/v4.0.0.tar.gz \
    https://github.com/QubesOS/qubes-windows-utils/archive/v4.0.0.tar.gz \
    https://github.com/QubesOS/qubes-core-qubesdb/archive/v4.0.10.tar.gz \
    https://github.com/QubesOS/qubes-gui-common/archive/v4.0.2.tar.gz \
    https://github.com/QubesOS/qubes-gui-agent-windows/archive/v4.0.0.tar.gz \
    https://github.com/QubesOS/qubes-installer-qubes-os-windows-tools/archive/v4.0.1-3.tar.gz \
    https://github.com/QubesOS/qubes-vmm-xen-windows-pvdrivers/archive/v4.0.0.tar.gz \
    https://github.com/QubesOS/qubes-vmm-xen-win-pvdrivers-xeniface/archive/mm_ff24d3b2.tar.gz 

# Download the latest stable xen drivers
RUN curl -s -LJ --remote-name-all -C - \
    http://xenbits.xen.org/pvdrivers/win/8.2.2/xenbus.tar \
    http://xenbits.xen.org/pvdrivers/win/8.2.2/xeniface.tar \
    http://xenbits.xen.org/pvdrivers/win/8.2.2/xenvif.tar \
    http://xenbits.xen.org/pvdrivers/win/8.2.2/xennet.tar \
    http://xenbits.xen.org/pvdrivers/win/8.2.2/xenvbd.tar

RUN curl -s -LJ --remote-name-all -C - \
    https://github.com/wixtoolset/wix3/releases/download/wix3111rtm/wix311-binaries.zip

# Extract wix binaries into the /opt directory
RUN unzip -d /opt/wix/ wix311-binaries.zip

WORKDIR /build
COPY *.* ./

