x64 : CC = /usr/bin/x86_64-w64-mingw32-gcc
x64 : DLLTOOL=/usr/bin/x86_64-w64-mingw32-dlltool
x64:  WINDRES=/usr/bin/x86_64-w64-mingw32-windres
x64 : DDKPATH=/usr/x86_64-w64-mingw32/sys-root/mingw/include/ddk
x64 : ARCH=x64
x64 : DEBUG=-D_DEBUG -DDBG

x86 : CC = /usr/bin/i686-w64-mingw32-gcc
x86 : DLLTOOL=/usr/bin/i686-w64-mingw32-dlltool
x86:  WINDRES=/usr/bin/i686-w64-mingw32-windres
x86 : DDKPATH=/usr/i686-w64-mingw32/sys-root/mingw/include/ddk
x86 : ARCH=x86
x86 : DEBUG=-U_DEBUG

CFLAGS += -I . -I $(PWD)/include  -I $(PWD)/$(ARCH) -I $(DDKPATH) -std=c11 -fgnu89-inline -DUNICODE $(DEBUG) -mwindows -D_WIN32_WINNT=0x0600
LDFLAGS += -L $(PWD)/$(ARCH) -L $(PWD)/xeniface/$(ARCH) -lxencontrol -lversion -lshlwapi -lwtsapi32 -luserenv -liphlpapi -lwsock32 -lsetupapi -lrpcrt4 -lole32 -lntdll -luuid -lcomctl32 -lgdi32 -lwinmm
BACKEND_VMM = xen
TARGETS = xencontrol.dll libxenvchan.dll libvchan.dll xenvchan-test.exe vchan-test.exe windows-utils.dll qubesdb-client.dll qubesdb-cmd.exe qubesdb-daemon.exe advertise-tools.exe ask-vm-and-run.exe network-setup.exe prepare-volume.exe qrexec-agent.exe qrexec-client-vm.exe qrexec-wrapper.exe relocate-dir.exe clipboard-copy.exe clipboard-paste.exe file-receiver.exe file-sender.exe get-image-rgba.exe open-in-vm.exe open-url.exe set-gui-mode.exe vm-file-editor.exe wait-for-logon.exe window-icon-updater.exe gui-agent.exe QgaWatchdog.exe create-device.exe disable-device.exe service-policy.exe uninstaller.exe qvgdi.dll qvmini.sys
OUTDIR = $(PWD)/$(ARCH)
WINEMU=wine
WIXPATH=/opt/wix
WINEPREFIX=/opt/wine
WINEARCH=win32
WINEDEBUG=warn+dll

prep86: 
	mkdir -p x86
	sed -i '/mi.h/d' qubes-gui-agent-windows-*/qvideo/gdi/support.c

prep64:
	mkdir -p x64

clean:
	rm -rf {x86,x64}
	rm -f *.msi

x64: prep64 $(TARGETS) sign wix

x86: prep86 $(TARGETS) sign wix

sign:
	mv $(ARCH)/qvmini.sys $(ARCH)/qvmini_unsigned.sys
	mv $(ARCH)/qvgdi.dll $(ARCH)/qvgdi_unsigned.dll
	osslsigncode sign -pass pass -certs authenticode.spc -key authenticode.pvk -n "Qubes Tools" -t http://timestamp.verisign.com/scripts/timstamp.dll -in $(ARCH)/qvmini_unsigned.sys -out $(ARCH)/qvmini.sys
	osslsigncode sign -pass pass -certs authenticode.spc -key authenticode.pvk -n "Qubes Tools" -t http://timestamp.verisign.com/scripts/timstamp.dll -in $(ARCH)/qvgdi_unsigned.dll -out $(ARCH)/qvgdi.dll

wix:
	cp xen*/$(ARCH)/xen*.{dll,inf,cat,sys,exe} ./$(ARCH)
	cp qubes-core-agent-windows-*/src/qrexec-services/qubes.* ./$(ARCH)
	cp qubes-core-agent-windows-*/src/qrexec-services/*.ps1 ./$(ARCH)
	cp qubes-core-agent-windows-*/src/service-policy/service-policy.cfg ./$(ARCH)
	cp qubes-installer-qubes-os-windows-tools-*/power_settings.bat ./$(ARCH)
	cp qubes-gui-agent-windows-*/qvideo/qvideo.inf ./$(ARCH)
	cp qubes-installer-qubes-os-windows-tools-*/iso-README.txt ./
	cp qubes-installer-qubes-os-windows-tools-*/license.rtf ./$(ARCH)
	cp qubes-installer-qubes-os-windows-tools-*/qubes-logo.png ./$(ARCH)
	cp qubes-installer-qubes-os-windows-tools-*/qubes.ico ./$(ARCH)
	cp authenticode.crt ./$(ARCH)
	cd $(ARCH); \
	$(WINEMU) $(WIXPATH)/candle.exe -arch $(ARCH) -ext WixDifxAppExtension -ext WixIIsExtension ../qubes-tools.wxs -o qubes-tools.wixobj; \
	$(WINEMU) $(WIXPATH)/light.exe -sval qubes-tools.wixobj -ext WixDifxAppExtension -ext WixIIsExtension -ext WixUIExtension "Z:/opt/wix/difxapp_$(ARCH).wixlib" -o ../qubes-tools-$(ARCH).msi;
	##$(WINEMU) $(WIXPATH)/candle.exe -arch $(ARCH) -ext WixBalExtension ../qubes-tools.wxb -o /qubes-tools-exe.wixobj; \
	##$(WINEMU) $(WIXPATH)/light.exe -ext WixBalExtension -sval qubes-tools-exe.wixobj -o qubes-tools.exe;

xencontrol.dll: 
	cd qubes-vmm-xen-win-pvdrivers-xeniface-*/src/xencontrol/ && \
	$(CC) xencontrol.c -lsetupapi -I ../../include -DXENCONTROL_EXPORTS -DUNICODE -shared -o $(OUTDIR)/$@

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
	$(CC) xenvchan-test.c $(CFLAGS) -L$(PWD)/$(ARCH) -lxencontrol -lxenvchan -lwindows-utils -o $(OUTDIR)/$@

libvchan.dll: libxenvchan.dll
	cd qubes-core-vchan-xen-*/windows/src && \
	$(CC) dllmain.c io.c init.c $(CFLAGS) $(LDFLAGS) -lxenvchan -shared -o $(OUTDIR)/$@

vchan-test.exe: libvchan.dll windows-utils.dll
	$(CC) vchan-test.c $(CFLAGS) -L$(PWD)/$(ARCH) -lwindows-utils -lvchan -o $(OUTDIR)/$@

windows-utils.dll: libvchan.dll 
	cd qubes-windows-utils-*/src && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lvchan -DWINDOWSUTILS_EXPORTS -DNO_SHLWAPI_STRFCNS -shared -o $(OUTDIR)/$@

qubesdb-client.dll: windows-utils.dll
	cd qubes-core-qubesdb-*/client && \
	$(CC) qdb-client.c $(CFLAGS) $(LDFLAGS) -lwindows-utils -DQUBESDBCLIENT_API -shared -DWIN32 -o $(OUTDIR)/$@

qubesdb-cmd.exe: qubesdb-client.dll
	cd qubes-core-qubesdb-*/client && \
	$(CC) qubesdb-cmd.c $(CFLAGS) $(LDFLAGS) -lwindows-utils -lqubesdb-client -DWIN32 -o $(OUTDIR)/$@

qubesdb-daemon.exe: qubesdb-client.dll
	cd qubes-core-qubesdb-*/daemon && \
	$(CC) db-cmds.c db-daemon.c db-core.c buffer.c $(CFLAGS) $(LDFLAGS) -lwindows-utils -lqubesdb-client -lvchan -DWIN32 -o $(OUTDIR)/$@ 

advertise-tools.exe:
	cd qubes-core-agent-windows-*/src/advertise-tools && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -municode -o $(OUTDIR)/$@

ask-vm-and-run.exe:
	cd qubes-core-agent-windows-*/src/ask-vm-and-run && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -municode -o $(OUTDIR)/$@ 

network-setup.exe:
	cd qubes-core-agent-windows-*/src/network-setup && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils  -municode -o $(OUTDIR)/$@

prepare-volume.exe:
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
	$(CC) *.c $(CFLAGS) -mno-stack-arg-probe -e NtProcessStartup -Wl,--subsystem,native -lntdll -nostdlib -D__INTRINSIC_DEFINED__InterlockedAdd64 -municode -o $(OUTDIR)/$@

clipboard-copy.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/clipboard-copy && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -lvchan -municode -o $(OUTDIR)/$@

clipboard-paste.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/clipboard-paste && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -lvchan -municode -o $(OUTDIR)/$@

file-receiver.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/file-receiver && \
	$(CC) *.c ../common/filecopy*.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -municode -D_WIN32_WINNT_WIN7 -DNO_SHLWAPI_STRFCNS -o $(OUTDIR)/$@

file-sender.exe:
	cd qubes-core-agent-windows-*/src/qrexec-services/file-sender && \
        $(WINDRES) -i 'file-sender.rc' -o 'file-sender.res' -O coff && \
        $(CC) *.c file-sender.res ../common/filecopy*.c $(CFLAGS) $(LDFLAGS) -lqubesdb-client -lwindows-utils -municode -D_WIN32_WINNT_WIN7 -DNO_SHLWAPI_STRFCNS -o $(OUTDIR)/$@

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
        $(WINDRES) -i 'qga.rc' -o 'qga.res' -O coff && \
	$(CC) *.c qga.res $(CFLAGS) $(LDFLAGS) -lvchan -lwindows-utils -lqubesdb-client -o $(OUTDIR)/qga.exe

QgaWatchdog.exe:
	cd qubes-gui-agent-windows-*/watchdog && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -lvchan -lwindows-utils -municode -o $(OUTDIR)/$@

create-device.exe:
	cd qubes-gui-agent-windows-*/install-helper/create-device && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -municode -o $(OUTDIR)/$@

disable-device.exe:
	cd qubes-gui-agent-windows-*/install-helper/disable-device && \
	$(CC) *.c $(CFLAGS) $(LDFLAGS) -municode -o $(OUTDIR)/$@

qvgdi.dll:
	$(DLLTOOL) -k -d win32k.def -l $(OUTDIR)/libwin32k.a
	rm -f qubes-gui-agent-windows-*/qvideo/gdi/support.c
	cd qubes-gui-agent-windows-*/qvideo/gdi && \
	$(CC) *.c  -I ../../../include -I ../../include -I ./ -I $(OUTDIR) -I $(DDKPATH) -L $(OUTDIR) -lwin32k -lntoskrnl -lhal -lwmilib -nostdlib -Wl,--subsystem,native -e DrvEnableDriver -shared -D__INTRINSIC_DEFINED__InterlockedAdd64 $(DEBUG) -o $(OUTDIR)/$@

qvmini.sys:
	$(DLLTOOL) -k -d videoprt.def -l $(OUTDIR)/libvideoprt.a
	cd qubes-gui-agent-windows-*/qvideo/miniport && \
	$(CC) *.c  -I ../../../include -I ../../include -I ./ -I $(OUTDIR) -I $(DDKPATH) -L $(OUTDIR) -lvideoprt -lntoskrnl -lhal -nostdlib -Wl,--subsystem,native -shared -e DriverEntry@8 -D_NTOSDEF_ -DNOCRYPT -D__INTRINSIC_DEFINED__InterlockedAdd64 $(DEBUG) -o $(OUTDIR)/$@
