FROM registry.fedoraproject.org/fedora-minimal:latest

RUN microdnf install -y \
    mingw32-gcc mingw64-gcc mingw32-gcc-c++ mingw64-gcc-c++ \
    mingw32-winpthreads-static mingw64-winpthreads-static \
    mono-core cabextract wine.i686 tar unzip make curl vim-enhanced \
    genisoimage patch git svn file rpm-build createrepo 

# FIXME 
# dotnet unattended installation doesn't work on the latest wine
RUN microdnf install dnf libxcrypt-compat.i686
RUN dnf downgrade --releasever=28 -y wine.i686

RUN curl -s -LJ https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks > /usr/local/bin/winetricks && chmod +x /usr/local/bin/winetricks

ENV WINEDEBUG=-all WINEARCH=win32 WINEPREFIX=/opt/wine
RUN winetricks --unattended --verbose dotnet40
RUN curl -s -LJ --remote-name-all -C - \
    https://github.com/wixtoolset/wix3/releases/download/wix3111rtm/wix311-binaries.zip

# Extract wix binaries into the /opt directory
RUN unzip -d /opt/wix/ wix311-binaries.zip

WORKDIR /build
COPY * ./
