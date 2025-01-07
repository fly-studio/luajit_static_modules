# 静态编译luajit

静态编译luajit为独立文件，并且包含一些第三方库。


# 已经包含的第三方库

- [x] luajit
- [x] lua-cjson
- [x] lua-openssl
- [x] lua-protobuf
- [x] lua-sec
- [x] luasocket
- [x] inspect-lua
- [x] serpent

## 可以require的模块
```
cjson
inspect
ltn12
mime
mime.core
openssl
pb
pb.buffer
pb.conv
pb.io
pb.slice
pb.unsafe
protoc
serpent
socket
socket.core
socket.ftp
socket.headers
socket.http
socket.smtp
socket.tp
socket.url
ssl
ssl.config
ssl.context
ssl.core
ssl.https
ssl.x509
```

# 编译方法

可静态编译的操作系统:
- [X] mingw
- [X] linux

Todo:
- [ ] openssl 静态编译


## Linux
```
apt install build-essential openssl-devel vim
git clone --recursive https://github.com/fly-studio/luajit_static_modules
cd luajit_static_modules
make
```

## MingW
```
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-make openssl-devel vim
git clone --recursive https://github.com/fly-studio/luajit_static_modules
cd luajit_static_modules
mingw32-make
```

会编译成一个独立的luajit.exe，只依赖OpenSSL的libssl-3-x64.dll、libcrypto-3-x64.dll
