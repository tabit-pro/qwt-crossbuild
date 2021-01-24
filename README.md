# DEPRECATED

Qubes Windows Tools crossbuild environment based on mingw, wine and docker is deprecated in favor of common rpm package building process.
Take a look at https://github.com/tabit-pro/Qway-qubes-repo/tree/master/qubes-windows-tools


[![Build Status](https://travis-ci.org/tabit-pro/qwt-crossbuild.svg?branch=master)](https://travis-ci.org/tabit-pro/qwt-crossbuild)

In comparison with the original ITL's Qubes Tools qwt-crossbuild contains several in-progress improvements:

- [x] rebuild QWT utils (mingw, x86, x86\_64)
- [x] include updated xen pv drivers (8.2.2)
- [x] avoid high cpu consumption (move qga CreateEvent outside an event processing loop)
- [x] fix dhcp dependencies (winhttproxy wants to stay alive)
- [x] hide command prompt windows during setup execution (WixQuiteExec)
- [x] sign and install drivers without prompt (libwdi-based pkihelper utility)
- [x] remove format dialog (diskpart instead of prepare-volume)
- [ ] troubleshoot bsod errors (0x101, 0xc5, 0x50)
- [x] prepare reproducible/deterministic build (binaries only)
- [x] support Qubes-r4.1 (qrexec v2 backward compatibility)

## QWT Runtime prerequisuites

1. Fully/partially updated Windows 7/10
1. Testsigning mode on
1. Backup

## Feature status
| Feature | Windows 7 x64 (en,ru)| Windows 10 x64 (en,ru) |
| --- | :---: | :---: |
| Qubes Video Driver | + | - |
| Qubes Network Setup | + | + |
| Private Volume Setup (move profiles)  | + | + |
| File sender/receiver | + | + |
| Clipboard Copy/Paste | + | + |
| Application shortcuts | + | + |
| Copy/Edit in Disposible VM | + | + |
| Block device | + | + |
| USB device | - | - |
| Audio | - | - |

## Build QWT

```shell_session
$ git clone https://github.com/tabit-pro/qwt-crossbuild .
$ docker build -t tabit/qwt .
$ mkdir -p ~/qwtiso
$ docker run -v $(pwd):/src -v ~/qwtiso:/build/noarch -it tabit/qwt sh -c "cp -fr /src/* ./ || true && make sources && rpmbuild -bb --define '_sourcedir /build' --define '_rpmdir /build' *.spec && cd noarch && createrepo ./"
```

