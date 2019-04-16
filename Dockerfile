FROM fedora-minimal:28

RUN microdnf install -y mingw32-gcc mingw64-gcc \
    mono-core osslsigncode \
    tar unzip make curl vim-enhanced \
    wine genisoimage patch git cabextract \
    file rpm-build createrepo msitools

RUN mkdir -p build
WORKDIR build
COPY Makefile ./
COPY *.* ./

# Get the latest source tree
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
    https://github.com/QubesOS/qubes-vmm-xen-win-pvdrivers-xeniface/archive/mm_ff24d3b2.tar.gz \
    || true

# Download the latest stable xen drivers
RUN curl -s -LJ --remote-name-all -C - \
    http://xenbits.xen.org/pvdrivers/win/8.2.2/xenbus.tar \
    http://xenbits.xen.org/pvdrivers/win/8.2.2/xeniface.tar \
    http://xenbits.xen.org/pvdrivers/win/8.2.2/xenvif.tar \
    http://xenbits.xen.org/pvdrivers/win/8.2.2/xennet.tar \
    http://xenbits.xen.org/pvdrivers/win/8.2.2/xenvbd.tar \
    || true

ENV WINEDEBUG=-all WINEARCH=win32 WINEPREFIX=/opt/wine/
RUN curl -s -LJ --remote-name-all -C - \
    https://github.com/wixtoolset/wix3/releases/download/wix3111rtm/wix311-binaries.zip || true
RUN curl -s -LJ https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks > \
    /usr/local/bin/winetricks && chmod +x /usr/local/bin/winetricks
RUN winetricks --unattended dotnet40

# Extract wix binaries into the /opt directory
RUN unzip -d /opt/wix/ wix311-binaries.zip

# Unpack everything else into the workdir
RUN for i in $(ls *.tar.gz); do tar -zxvf $i; done
RUN cat xen*.tar | tar -xvf - -i

# FIXME: 
# replace ugly sed stuff with a proper patchset
RUN sh ./prep.sh

RUN sh ./setup-demo-cert.sh

# Comment out the following to build qwt manually
#RUN make all
#RUN make wix
#RUN rpmbuild -bb --define '_sourcedir /build' --define '_rpmdir /build' *.spec 
