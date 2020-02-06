FROM registry.fedoraproject.org/fedora-minimal:28

RUN microdnf install -y mingw32-gcc mingw64-gcc \
    mono-core cabextract \
    mingw32-winpthreads-static \
    mingw64-winpthreads-static \
    mingw32-gcc-c++ mingw64-gcc-c++ \
    tar unzip make curl vim-enhanced \
    wine wine-mono genisoimage patch git svn \
    spectool file rpm-build createrepo 

ENV WINEDEBUG=-all WINEARCH=win32 WINEPREFIX=/opt/wine
RUN curl -s -LJ https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks > \
    /usr/local/bin/winetricks && chmod +x /usr/local/bin/winetricks
RUN winetricks --unattended dotnet40

RUN curl -s -LJ --remote-name-all -C - \
    https://github.com/wixtoolset/wix3/releases/download/wix3111rtm/wix311-binaries.zip

# Extract wix binaries into the /opt directory
RUN unzip -d /opt/wix/ wix311-binaries.zip

WORKDIR /build
COPY * ./

