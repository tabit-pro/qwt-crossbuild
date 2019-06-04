x64 : CC = /usr/bin/x86_64-w64-mingw32-gcc
x64 : CXX = /usr/bin/x86_64-w64-mingw32-g++
x64 : DLLTOOL=/usr/bin/x86_64-w64-mingw32-dlltool
x64 : STRIP=/usr/bin/x86_64-w64-mingw32-strip
x64:  WINDRES=/usr/bin/x86_64-w64-mingw32-windres
x64:  WINDMC=/usr/bin/x86_64-w64-mingw32-windmc
x64 : DDKPATH=/usr/x86_64-w64-mingw32/sys-root/mingw/include/ddk
x64 : ARCH=x64
x64 : DEBUG=-U_DEBUG -UDBG -UDEBUG

x86 : CC = /usr/bin/i686-w64-mingw32-gcc
x86 : CXX = /usr/bin/i686-w64-mingw32-g++
x86 : DLLTOOL=/usr/bin/i686-w64-mingw32-dlltool
x86 : STRIP=/usr/bin/i686-w64-mingw32-strip
x86:  WINDRES=/usr/bin/i686-w64-mingw32-windres
x86:  WINDMC=/usr/bin/i686-w64-mingw32-windmc
x86 : DDKPATH=/usr/i686-w64-mingw32/sys-root/mingw/include/ddk
x86 : ARCH=x86
x86 : DEBUG=-U_DEBUG -UDBG -UDEBUG

QWTVERSION = -D__MINGW__ -DQTW_FILEVERSION=4,0,0,0 -DQTW_FILEVERSION_STR='\"4.0.0.0\0\"' -DQTW_PRODUCTVERSION=QTW_FILEVERSION -DQTW_PRODUCTVERSION_STR=QTW_FILEVERSION_STR
HPATH = -I . -I $(PWD) -I $(PWD)/include -I $(DDKPATH) -I $(PWD)/qubes-windows-utils-*/include/ -I $(PWD)/qubes-vmm-xen-windows-pvdrivers-*/include/ -I $(PWD)/qubes-core-qubesdb-*/include/ -I $(PWD)/qubes-core-agent-windows-*/src/qrexec-services/common/ -I $(PWD)/qubes-gui-agent-windows-*/include/ -I $(PWD)/qubes-gui-common-*/include/ -I $(PWD)/qubes-windows-utils-*/include/ -I $(PWD)/qubes-core-vchan-xen-*/windows/include/ -I $(PWD)/qubes-vmm-xen-win-pvdrivers-xeniface-*/include/
CFLAGS += -std=c11 -fgnu89-inline -D__MINGW__ -D_INC_TCHAR -DNO_SHLWAPI_STRFCNS -DUNICODE -D_UNICODE $(DEBUG) -mwindows -D_WIN32_WINNT=0x0600 $(HPATH)
LDFLAGS += -L $(PWD)/$(ARCH) -L $(PWD)/xeniface/$(ARCH) -lxencontrol -lversion -lshlwapi -lwtsapi32 -luserenv -liphlpapi -lwsock32 -lsetupapi -lrpcrt4 -lole32 -lntdll -luuid -lcomctl32 -lgdi32 -lwinmm -Wl,--as-needed -Wl,--no-insert-timestamp
TARGETS = vchan-test.exe xenvchan-test.exe prepare-volume.exe service-policy.exe create-device.exe disable-device.exe devcon.exe relocate-dir.exe pkihelper.exe xencontrol.dll libxenvchan.dll libvchan.dll windows-utils.dll qubesdb-client.dll qubesdb-cmd.exe qubesdb-daemon.exe advertise-tools.exe ask-vm-and-run.exe network-setup.exe qrexec-agent.exe qrexec-client-vm.exe qrexec-wrapper.exe clipboard-copy.exe clipboard-paste.exe file-receiver.exe file-sender.exe get-image-rgba.exe open-in-vm.exe open-url.exe set-gui-mode.exe vm-file-editor.exe wait-for-logon.exe window-icon-updater.exe gui-agent.exe QgaWatchdog.exe qvgdi.dll qvmini.sys
OUTDIR = $(PWD)/$(ARCH)
WINEMU=wine
WIXPATH=/opt/wix
WINEPREFIX=/opt/wine
WINEARCH=win32
WINEDEBUG=warn+dll
TIMESTAMP='last sunday 00:00'
UPPERLIST=Windows.h Wtsapi32.h WtsApi32.h Lmcons.h Shlwapi.h SetupAPI.h ShlObj.h Knownfolders.h Strsafe.h Shellapi.h
UPPERPATH=/usr/x86_64-w64-mingw32/sys-root/mingw/include


sources:
	mkdir -p devcon
	svn --force export https://github.com/microsoft/Windows-driver-samples/trunk/setup/devcon && tar -czvf devcon.tar.gz devcon
	spectool -g *.spec

gencert:
	openssl req -x509 -newkey rsa:4096 -passout pass:"pass" -keyout authenticode.key -out authenticode.crt -days 365 -subj "/C=CA/ST=DemoState/L=DemoDepartment/O=DemoCompany/OU=DemoUnit/CN=demo/emailAddress=root@demo"
	/usr/bin/openssl pkcs12 -export -out authenticode.pfx -inkey authenticode.key -in authenticode.crt -passout pass:"pass" -passin pass:"pass"
	/usr/bin/openssl pkcs12 -in authenticode.pfx -nocerts -nodes -out key.pem -password pass:"pass"
	/usr/bin/openssl rsa -in key.pem -outform PVK -pvk-strong -out authenticode.pvk -passout pass:"pass"
	/usr/bin/openssl pkcs12 -in authenticode.pfx -nokeys -nodes -out cert.pem -passin pass:"pass"
	/usr/bin/openssl crl2pkcs7 -nocrl -certfile cert.pem -outform DER -out authenticode.spc

prep: 
	mkdir -p x86
	mkdir -p x64
	mkdir -p include
	mkdir -p include
	for value in ${UPPERLIST}; do ln -sf ${UPPERPATH}/$${value,,} include/$$value; done;

clean:
	rm -rf {x86,x64}
	rm -f *.msi

x64: prep $(TARGETS) sign wix

x86: prep $(TARGETS) sign wix

sign:
	mv $(ARCH)/qvmini.sys $(ARCH)/qvmini_unsigned.sys
	mv $(ARCH)/qvgdi.dll $(ARCH)/qvgdi_unsigned.dll
	faketime $(TIMESTAMP) osslsigncode sign -pass pass -certs authenticode.spc -key authenticode.pvk -n "Qubes Tools" -in $(ARCH)/qvmini_unsigned.sys -out $(ARCH)/qvmini.sys
	faketime $(TIMESTAMP) osslsigncode sign -pass pass -certs authenticode.spc -key authenticode.pvk -n "Qubes Tools" -in $(ARCH)/qvgdi_unsigned.dll -out $(ARCH)/qvgdi.dll

wix:
	cp xen*/$(ARCH)/xen*.{dll,inf,cat,sys,exe} ./$(ARCH)
	cp qubes-core-agent-windows-*/src/qrexec-services/qubes.* ./$(ARCH)
	cp qubes-core-agent-windows-*/src/qrexec-services/*.ps1 ./$(ARCH)
	cp qubes-installer-qubes-os-windows-tools-*/power_settings.bat ./$(ARCH)
	cp disable_svc.bat ./$(ARCH)
	cp diskpart.txt ./$(ARCH)
	cp authenticode.crt ./$(ARCH)
	cp qubes-gui-agent-windows-*/qvideo/qvideo.inf ./$(ARCH)
	cp qubes-installer-qubes-os-windows-tools-*/iso-README.txt ./
	cp qubes-installer-qubes-os-windows-tools-*/license.rtf ./$(ARCH)
	cp qubes-installer-qubes-os-windows-tools-*/qubes-logo.png ./$(ARCH)
	cp qubes-installer-qubes-os-windows-tools-*/qubes.ico ./$(ARCH)
	cd $(ARCH); \
	$(WINEMU) $(WIXPATH)/candle.exe -arch $(ARCH) -ext WixDifxAppExtension -ext WixIIsExtension ../qubes-tools.wxs -o qubes-tools.wixobj; \
	$(WINEMU) $(WIXPATH)/light.exe -sval qubes-tools.wixobj -ext WixDifxAppExtension -ext WixUIExtension -ext WixIIsExtension -ext WixUtilExtension "Z:/opt/wix/difxapp_$(ARCH).wixlib" -o ../qubes-tools-$(ARCH).msi;

devcon.exe: 
	cd devcon/ && \
	$(WINDMC) msg.mc && \
	$(WINDRES) devcon.rc rc.so && \
	$(CXX) -municode -Wno-write-strings $(LDFLAGS) -D__MINGW__ -DWIN32_LEAN_AND_MEAN=1 -DUNICODE -D_UNICODE *.cpp rc.so -lsetupapi -lole32 -static-libstdc++ -static-libgcc -static -lpthread -o $(OUTDIR)/$@

pkihelper.exe: windows-utils.dll 
	$(CC) pkihelper.c $(HPATH) -L $(OUTDIR) -Wl,--no-insert-timestamp -lwindows-utils -o $(OUTDIR)/$@

xencontrol.dll: 
	cd qubes-vmm-xen-win-pvdrivers-xeniface-*/src/xencontrol/ && \
	$(CC) $(CFLAGS) xencontrol.c -lsetupapi -I ../../include -DXENCONTROL_EXPORTS -DUNICODE -shared -o $(OUTDIR)/$@

uninstaller.exe:
	cd qubes-installer-qubes-os-windows-tools-*/uninstaller/ && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -municode -o $(OUTDIR)/$@

service-policy.exe:
	cd ./qubes-core-agent-windows-*/src/service-policy && \
	mcs Main.cs Properties/AssemblyInfo.cs -r:System.ServiceProcess.dll -out:$(OUTDIR)/$@

libxenvchan.dll: xencontrol.dll
	cd qubes-vmm-xen-windows-pvdrivers-*/src/libxenvchan && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -DXENVCHAN_EXPORTS -D_NTOS_ -shared -o $(OUTDIR)/$@

xenvchan-test.exe: libxenvchan.dll windows-utils.dll
	$(CC) qubes-vmm-xen-windows-pvdrivers-*/src/xenvchan-test/xenvchan-test.c $(CFLAGS) -L$(PWD)/$(ARCH) -lxencontrol -lxenvchan -lwindows-utils -o $(OUTDIR)/$@

libvchan.dll: libxenvchan.dll
	cd qubes-core-vchan-xen-*/windows/src && \
	$(CC) dllmain.c io.c init.c $(CFLAGS) $(LDFLAGS) -lxenvchan -shared -o $(OUTDIR)/$@

vchan-test.exe: libvchan.dll windows-utils.dll
	$(CC) qubes-core-vchan-xen-*/windows/src/vchan-test.c $(CFLAGS) -L$(PWD)/$(ARCH) -lwindows-utils -lvchan -o $(OUTDIR)/$@

windows-utils.dll: libvchan.dll 
	cd qubes-windows-utils-*/src && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lvchan -DWINDOWSUTILS_EXPORTS -shared -o $(OUTDIR)/$@

qubesdb-client.dll: windows-utils.dll
	cd qubes-core-qubesdb-*/client && \
	$(CC) qdb-client.c $(CFLAGS) $(LDFLAGS) -lwindows-utils -DQUBESDBCLIENT_API -shared -DWIN32 -o $(OUTDIR)/$@

qubesdb-cmd.exe: qubesdb-client.dll
	cd qubes-core-qubesdb-*/client && \
	$(CC) qubesdb-cmd.c $(CFLAGS) $(LDFLAGS) -lwindows-utils -lqubesdb-client -DWIN32 -o $(OUTDIR)/$@

qubesdb-daemon.exe: qubesdb-client.dll
	cd qubes-core-qubesdb-*/daemon && \
	$(CC) db-cmds.c db-daemon.c db-core.c buffer.c $(CFLAGS) $(LDFLAGS) -D_STRSAFE_H_INCLUDED_ -lwindows-utils -lqubesdb-client -lvchan -DWIN32 -o $(OUTDIR)/$@ 

advertise-tools.exe:
	cd qubes-core-agent-windows-*/src/advertise-tools && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -municode -o $(OUTDIR)/$@

ask-vm-and-run.exe:
	cd qubes-core-agent-windows-*/src/ask-vm-and-run && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -municode -o $(OUTDIR)/$@ 

network-setup.exe:
	cd qubes-core-agent-windows-*/src/network-setup && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils  -municode -o $(OUTDIR)/$@

prepare-volume.exe: qubesdb-client.dll
	cd qubes-core-agent-windows-*/src/prepare-volume && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -municode -o $(OUTDIR)/$@

qrexec-agent.exe:
	cd qubes-core-agent-windows-*/src/qrexec-agent && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -lvchan -municode -o $(OUTDIR)/$@ 

qrexec-client-vm.exe:
	cd qubes-core-agent-windows-*/src/qrexec-client-vm && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -lvchan -municode -o $(OUTDIR)/$@

qrexec-wrapper.exe:
	cd qubes-core-agent-windows-*/src/qrexec-wrapper && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -lvchan -municode -o $(OUTDIR)/$@

relocate-dir.exe:
	cd qubes-core-agent-windows-*/src/relocate-dir && \
	$(CC) *.c $(CFLAGS) -e NtProcessStartup -Wl,--subsystem,native -L $(OUTDIR) -lntdll -nostdlib -D__INTRINSIC_DEFINED__InterlockedAdd64 -fstack-check -Wl,--stack,16777216 -mno-stack-arg-probe -municode -Wl,--no-insert-timestamp -o $(OUTDIR)/$@

clipboard-copy.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/clipboard-copy && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -lvchan -municode -o $(OUTDIR)/$@

clipboard-paste.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/clipboard-paste && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -lvchan -municode -o $(OUTDIR)/$@

file-receiver.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/file-receiver && \
	$(CC) *.c ../common/filecopy*.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -municode -D_WIN32_WINNT_WIN7 -o $(OUTDIR)/$@

file-sender.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/file-sender && \
        $(WINDRES) -i 'file-sender.rc' -o 'file-sender.res' -O coff && \
        $(CC) *.c file-sender.res ../common/filecopy*.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -municode -D_WIN32_WINNT_WIN7 -o $(OUTDIR)/$@

get-image-rgba.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/get-image-rgba && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -lvchan -municode -o $(OUTDIR)/$@

open-in-vm.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/open-in-vm && \
	$(CC) *.c ../common/filecopy*.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -municode -lvchan -o $(OUTDIR)/$@

open-url.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/open-url && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -lvchan -municode -o $(OUTDIR)/$@

set-gui-mode.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/set-gui-mode && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -lvchan -municode -o $(OUTDIR)/$@

vm-file-editor.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/vm-file-editor && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -lvchan -municode -o $(OUTDIR)/$@

wait-for-logon.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/wait-for-logon && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -lvchan -municode -o $(OUTDIR)/$@

window-icon-updater.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/window-icon-updater && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -lvchan -municode -o $(OUTDIR)/$@

gui-agent.exe:
	cd qubes-gui-agent-windows-*/gui-agent && \
	$(WINDRES) $(QWTVERSION) -I ../include -i qga.rc -o qga.res -O coff && \
	$(CC) *.c qga.res $(CFLAGS) $(LDFLAGS) -lvchan -municode -DUNICODE -D_UNICODE -lwindows-utils -lqubesdb-client -lpsapi -o $(OUTDIR)/qga.exe

QgaWatchdog.exe:
	cd qubes-gui-agent-windows-*/watchdog && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lvchan -lwindows-utils -municode -o $(OUTDIR)/$@

create-device.exe:
	cd qubes-gui-agent-windows-*/install-helper/create-device && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -mconsole -municode -o $(OUTDIR)/$@

disable-device.exe:
	cd qubes-gui-agent-windows-*/install-helper/disable-device && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -mconsole -municode -o $(OUTDIR)/$@

qvgdi.dll:
	$(DLLTOOL) -k -d win32k.def -t win32k -l $(OUTDIR)/libwin32k.a
	$(STRIP) --enable-deterministic-archives --strip-dwo $(OUTDIR)/libwin32k.a
	rm -f qubes-gui-agent-windows-*/qvideo/gdi/support.c
	cd qubes-gui-agent-windows-*/qvideo/gdi && \
	$(CC) *.c $(HPATH) -L $(OUTDIR) -lwin32k -lntoskrnl -lhal -lwmilib -nostdlib -municode -DUNICODE -D_UNICODE -D__MINGW__ -Wl,--subsystem,native -Wl,--no-insert-timestamp -e DrvEnableDriver -shared -D__INTRINSIC_DEFINED__InterlockedAdd64 $(DEBUG) -o $(OUTDIR)/$@

qvmini.sys:
	$(DLLTOOL) -k -d videoprt.def -t videoprt -l $(OUTDIR)/libvideoprt.a
	$(STRIP) --enable-deterministic-archives --strip-dwo $(OUTDIR)/libvideoprt.a
	cd qubes-gui-agent-windows-*/qvideo/miniport && \
	rm -f list.h && \
	$(CC) *.c $(HPATH) -L $(OUTDIR) -lvideoprt -lntoskrnl -lhal -nostdlib -municode -DUNICODE -D_UNICODE -D__MINGW__ -Wl,--subsystem,native -Wl,--no-insert-timestamp -shared -e DriverEntry -D_NTOSDEF_ -DNOCRYPT -D__INTRINSIC_DEFINED__InterlockedAdd64 $(DEBUG) -o $(OUTDIR)/$@
