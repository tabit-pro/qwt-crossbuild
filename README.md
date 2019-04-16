# qwt-crossbuild
Qubes Windows Tools crossbuild environment based on mingw, wine and docker

## Getting Started

```shell_session
$ git clone https://github.com/tabit-pro/qwt-crossbuild .
$ docker build --rm -t qubes .
$ mkdir -p ~/qwtiso
```

## Build QWT

```shell_session
$ docker run -v ~/qwtiso:/build/noarch -v $PWD/qubes-windows-tools.spec:/build/qubes-windows-tools.spec -v $PWD/Makefile:/build/Makefile -it qubes sh -c "make x86 && make x64 && rpmbuild -bb --define '_sourcedir /build' --define '_rpmdir /build' *.spec && cd noarch && createrepo ./"
```
