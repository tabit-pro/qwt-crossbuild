#!/bin/bash

sed -i -e 's/, __VA_ARGS__/,##__VA_ARGS__/' qubes-vmm-xen-win-pvdrivers-xeniface-*/src/xencontrol/xencontrol_private.h
sed -i -e 's/, __VA_ARGS__/,##__VA_ARGS__/' qubes-vmm-xen-windows-pvdrivers-*/src/libxenvchan/io.c 
sed -i -e 's/, __VA_ARGS__/,##__VA_ARGS__/' qubes-vmm-xen-windows-pvdrivers-*/src/libxenvchan/init.c 
sed -i -e 's/, __VA_ARGS__/,##__VA_ARGS__/' qubes-core-vchan-xen-*/windows/src/libvchan_private.h 

sed -i '/winioctl.h/d' qubes-vmm-xen-win-pvdrivers-xeniface-*/src/xencontrol/xencontrol.c

sed -i "/version_common.rc/d" qubes-gui-agent-windows-*/gui-agent/qga.rc
sed -i -e "s/#include \"wdk.h\"/#include \"customddkinc.h\"\n#include \"wdk.h\"/"  qubes-core-agent-windows-*/src/qrexec-services/file-receiver/file-receiver.c

sed -i -e 's/__in_opt/SAL__in_opt/g' qubes-gui-agent-windows-*/qvideo/gdi/enable.c
sed -i -e 's/__out_bcount_opt/SAL__out_bcount_opt/g' qubes-gui-agent-windows-*/qvideo/gdi/enable.c
sed -i -e 's/<stddef.h>/<stddef.h>\n#include <driverspecs.h>/' qubes-gui-agent-windows-*/qvideo/gdi/driver.h
sed -i -e 's/__inout_bcount/SAL__inout_bcount/g' qubes-gui-agent-windows-*/qvideo/miniport/qvmini.*

sed -i -e 's/varargs.h/stdarg.h/' qubes-vmm-xen-win-pvdrivers-xeniface-*/include/xencontrol.h 
sed -i '/strsafe.h/d' qubes-core-agent-windows-*/src/prepare-volume/prepare-volume.h 
sed -i '/strsafe.h/d' qubes-core-agent-windows-*/src/qrexec-agent/qrexec-agent.c 
sed -i '/strsafe.h/d' qubes-core-agent-windows-*/src/qrexec-wrapper/qrexec-wrapper.c 
sed -i '/strsafe.h/d' qubes-core-qubesdb-*/daemon/db-core.c 
sed -i -e "s/#include <service.h>/#include <service.h>\n#include <netioapi.h>/" qubes-core-agent-windows-*/src/network-setup/qubes-network-setup.c 
sed -i -e "s/#include <devpkey.h>/#include <devpkey.h>\n#include \"customddkinc.h\"\n#include \"setupapifn.h\"/" qubes-core-agent-windows-*/src/prepare-volume/device.c 
sed -i -e "s/#include <stdlib.h>/#include <stdlib.h>\n#include \"customddkinc.h\"/" qubes-core-agent-windows-*/src/prepare-volume/disk.c 
sed -i -e "s/#include <qubes-string.h>/#include <qubes-string.h>\n#include \"customddkinc.h\"/" qubes-core-agent-windows-*/src/prepare-volume/prepare-volume.c 
sed -i -e "s/#include <strsafe.h>/#include \"customddkinc.h\"\n#include \"setupapifn.h\"/"  qubes-gui-agent-windows-*/install-helper/create-device/create-device.c 
sed -i -e "s/#include <strsafe.h>/#include \"customddkinc.h\"\n#include \"setupapifn.h\"/"  qubes-gui-agent-windows-*/install-helper/disable-device/disable-device.c 
sed -i '/TEXT/d' qubes-core-agent-windows-*/src/relocate-dir/main.c 
sed -i -e "s/#include <intrin.h>//" qubes-vmm-xen-windows-pvdrivers-*/src/libxenvchan/io.c
sed -i -e "s/InterlockedAnd8/InterlockedAnd/" qubes-vmm-xen-windows-pvdrivers-*/src/libxenvchan/io.c
sed -i 's/HANDLE/PXENCONTROL_CONTEXT/' qubes-core-vchan-xen-*/windows/src/libvchan_private.h 
sed -i -e 's/^void SvcStop/static void SvcStop/' qubes-windows-utils-*/src/service.c 
sed -i -e 's/^void WINAPI SvcMain/static void WINAPI SvcMain/' qubes-windows-utils-*/src/service.c 
sed -i -e 's/^ULONG ProcessUpdatedWindows/static ULONG ProcessUpdatedWindows/' qubes-gui-agent-windows-*/gui-agent/main.c 
sed -i -e 's/^DWORD QpsConnectClient/static DWORD QpsConnectClient/' qubes-windows-utils-*/src/pipe-server.c 
sed -i -e 's/^void WINAPI SvcMain/static void WINAPI SvcMain/' qubes-windows-utils-*/src/pipe-server.c 
sed -i -e 's/^void QpsDisconnectClientInternal/static void QpsDisconnectClientInternal/' qubes-windows-utils-*/src/pipe-server.c 
sed -i -e 's/<winnt.h>/<winnt.h>\n#include <driverspecs.h>/' qubes-windows-utils-*/include/list.h 
sed -i -e 's/CFORCEINLINE/FORCEINLINE/' qubes-windows-utils-*/include/list.h 
sed -i -e "s/<dderror.h>/<ntdef.h>\n#include <dderror.h>/" qubes-gui-agent-windows-*/qvideo/miniport/qvmini.h
sed -i -e "s/<video.h>/<video.h>\n#include <windows.h>\n#include <specstrings.h>/" qubes-gui-agent-windows-*/qvideo/miniport/qvmini.h
sed -i -e 's/#define.*QFN.*$/#define QFN "[QVMINI] "/' qubes-gui-agent-windows-*/qvideo/miniport/qvmini.h
sed -i -e 's/#define.*QFN.*$/#define QFN "[QVMINI] "/' qubes-gui-agent-windows-*/qvideo/miniport/memory.c

cp -f qubes-windows-utils-*/include/list.h qubes-gui-agent-windows-*/qvideo/miniport/
sed -i -e "s/<ntddk.h>/<ntddk.h>\n#include <driverspecs.h>/" qubes-gui-agent-windows-*/qvideo/miniport/ddk_video.h
sed -i '/CatalogFile/d' qubes-gui-agent-windows-*/qvideo/qvideo.inf
mkdir -p include
cp qubes-vmm-xen-windows-pvdrivers-*/include/*.h include/
cp qubes-core-qubesdb-*/include/*.h include/
cp qubes-core-agent-windows-*/src/qrexec-services/common/*.h include/
cp qubes-gui-agent-windows-*/include/*.h include/
cp qubes-gui-common-*/include/*.h include/
cp qubes-windows-utils-*/include/*.h include/
cp qubes-core-vchan-xen-*/windows/include/*.h include/
cp qubes-vmm-xen-win-pvdrivers-xeniface-*/include/*.h include/
cp file-sender.rc qubes-core-agent-windows-*/src/qrexec-services/file-sender/

sed -i -e 's/\" __FUNCTION__ \"//g' qubes-gui-agent-windows-*/qvideo/gdi/support.h
cp -f enable.c qubes-gui-agent-windows-*/qvideo/gdi/
cp -f memory.c /build/qubes-gui-agent-windows-*/qvideo/miniport/
cp *.h include/

for i in Windows.h Wtsapi32.h WtsApi32.h Lmcons.h Shlwapi.h SetupAPI.h ShlObj.h Knownfolders.h Strsafe.h Shellapi.h; do 
    ln -s /usr/x86_64-w64-mingw32/sys-root/mingw/include/$(echo $i | tr '[:upper:]' '[:lower:]') include/$i 
done 

