# 静态编译luajit

静态编译luajit，并且包含一些第三方库

- [X] luajit
- [x] lua-cjson
- [x] lua-openssl
- [x] lua-protobuf
- [x] lua-sec
- [x] luasocket
- [x] inspect-lua
- [x] serpent

# 已经载入的模块
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

```
apt install vim build-essential openssl-devel
git submodule update --init
make
```

在mingw环境下测试编译通过，应该不支持visual c++