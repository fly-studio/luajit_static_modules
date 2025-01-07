CC=gcc
AR=ar
CFLAGS= -O2 -Wall -fPIC -I luajit/src
SOCKET_LIB=


ifeq (Windows,$(findstring Windows,$(OS))$(MSYSTEM)$(TERM))
  HOST_SYS= Windows
else
  HOST_SYS:= $(shell uname -s)
  ifneq (,$(findstring MINGW,$(HOST_SYS)))
    HOST_SYS= Windows
    HOST_MSYS= mingw
  endif
  ifneq (,$(findstring MSYS,$(HOST_SYS)))
    HOST_SYS= Windows
    HOST_MSYS= mingw
  endif
  ifneq (,$(findstring CYGWIN,$(HOST_SYS)))
    HOST_SYS= Windows
    HOST_MSYS= cygwin
  endif
endif


# windows下socket库
ifeq ($(HOST_SYS), Windows)
	SOCKET_LIB= -lws2_32
endif

# C 文件
LUA_CJSON_O= lua-cjson/lua_cjson.o lua-cjson/strbuf.o lua-cjson/fpconv.o
LUASOCKET_O= luasocket/src/luasocket.o luasocket/src/timeout.o luasocket/src/buffer.o luasocket/src/io.o luasocket/src/auxiliar.o luasocket/src/compat.o luasocket/src/options.o \
	luasocket/src/inet.o luasocket/src/except.o luasocket/src/select.o luasocket/src/tcp.o luasocket/src/udp.o luasocket/src/mime.o luasocket/src/compat.o
LUASEC_O= luasec/src/config.o luasec/src/context.o luasec/src/x509.o luasec/src/ssl.o luasec/src/ec.o luasec/src/options.o
LUA_PROTOBUF_O= lua-protobuf/pb.o
LUA_OPENSSL_O= lua-openssl/src/asn1.o lua-openssl/deps/auxiliar/auxiliar.o lua-openssl/src/bio.o lua-openssl/src/cipher.o lua-openssl/src/cms.o lua-openssl/src/compat.o \
     lua-openssl/src/crl.o lua-openssl/src/csr.o lua-openssl/src/dh.o lua-openssl/src/digest.o lua-openssl/src/dsa.o lua-openssl/src/ec.o lua-openssl/src/engine.o         \
     lua-openssl/src/hmac.o lua-openssl/src/lbn.o lua-openssl/src/lhash.o lua-openssl/src/misc.o lua-openssl/src/ocsp.o lua-openssl/src/openssl.o lua-openssl/src/ots.o    \
     lua-openssl/src/pkcs12.o lua-openssl/src/pkcs7.o lua-openssl/src/pkey.o lua-openssl/src/rsa.o lua-openssl/src/ssl.o lua-openssl/src/th-lock.o lua-openssl/src/util.o  \
     lua-openssl/src/x509.o lua-openssl/src/xattrs.o lua-openssl/src/xexts.o lua-openssl/src/xname.o lua-openssl/src/xstore.o lua-openssl/src/xalgor.o         \
     lua-openssl/src/param.o lua-openssl/src/kdf.o                                                             \
     lua-openssl/src/callback.o lua-openssl/src/srp.o lua-openssl/src/mac.o lua-openssl/deps/auxiliar/subsidiar.o

# 根据操作系统确定 socket 的实现方式
ifeq ($(HOST_SYS), Windows)
    LUASOCKET_O += luasocket/src/wsocket.o
else
	LUASOCKET_O += luasocket/src/usocket.o \
                  luasocket/src/serial.o \
                  luasocket/src/unixstream.o \
                  luasocket/src/unixdgram.o \
                  luasocket/src/unix.o
endif

LIB_O= $(LUASOCKET_O) $(LUA_CJSON_O) $(LUASEC_O) $(LUA_PROTOBUF_O) $(LUA_OPENSSL_O) 3rd.o

# LUA 文件
LUASOCKET_LUA_O= luasocket/src/ltn12_lua.o luasocket/src/socket_lua.o luasocket/src/mime_lua.o luasocket/src/http_lua.o luasocket/src/url_lua.o luasocket/src/ftp_lua.o luasocket/src/smtp_lua.o luasocket/src/headers_lua.o luasocket/src/tp_lua.o
LUASEC_LUA_O= luasec/src/https_lua.o luasec/src/ssl_lua.o
INSPECT_LUA_O= inspect.lua/inspect_lua.o
SERPENT_LUA_O= serpent/src/serpent_lua.o
LUA_PROTOBUF_LUA_O= lua-protobuf/protoc_lua.o
LUA_O= $(LUASOCKET_LUA_O) $(LUASEC_LUA_O) $(INSPECT_LUA_O) $(SERPENT_LUA_O) $(LUA_PROTOBUF_LUA_O)


# 静态库
LIB_A= lua_static_modules.a

all: make_luajit

# 修改 lua_cjson.c 因为luaL_setfuncs是lua的导出函数，有冲突
lua-cjson/lua_cjson_modified.c: lua-cjson/lua_cjson.c
	sed 's|luaL_setfuncs|luaL__setfuncs|g' $< > $@

# lua_cjson.o 使用 lua_cjson_modified.c 来编译
lua-cjson/lua_cjson.o: lua-cjson/lua_cjson_modified.c
	$(CC) $(CFLAGS) -c -o $@ $<

# luasec需要include luasocket/src的header文件
luasec/src/%.o: luasec/src/%.c
	$(CC) $(CFLAGS) -I luasec/src -c -o $@ $<

# openssl需要include deps/auxiliar的header文件
lua-openssl/%.o: lua-openssl/%.c
	$(CC) $(CFLAGS) -I lua-openssl/deps/auxiliar -I lua-openssl/deps/lua-compat/c-api/ -c -o $@ $<

# 将 .lua 文件转换为 .c 文件
%_lua.c: %.lua
	echo "Generating $@ from $<"
	xxd -i $< > $@

$(LUA_O): %_lua.o: %_lua.c
	@echo "Compiling $@ $<"
	$(CC) $(CFLAGS) -c -o $@ $<

# 将 .c 文件转换为 .o 文件
%.o: %.c
	@echo "Compiling $@ $<"
	$(CC) $(CFLAGS) -c -o $@ $<


# 生成静态库
$(LIB_A): $(LIB_O) $(LUA_O)
	$(AR) rcus $@ $(LIB_O) $(LUA_O)


LUAJIT_SRC_DIR = luajit/src
LUAJIT_C = $(LUAJIT_SRC_DIR)/luajit.c
LUAJIT_MODIFIED_C = $(LUAJIT_SRC_DIR)/luajit_modified.c
LUAJIT_DEP= $(LUAJIT_SRC_DIR)/Makefile.dep1

# 修改 luajit.c 文件
make_luajit: $(LIB_A) $(LUAJIT_MODIFIED_C) $(LUAJIT_DEP)
	 $(MAKE) -f Makefile -C luajit/src LIBS=" ../../lua_static_modules.a $(SOCKET_LIB) -lssl -lcrypto " BUILDMODE=static LUAJIT_O="luajit_modified.o"

# 生成 luajit_modified.c
$(LUAJIT_MODIFIED_C): $(LUAJIT_C)
	sed -e '/static int pmain(/i\
void register3rdModules(lua_State *L);\
' -e '/luaL_openlibs(L);/a\
  register3rdModules(L);\
' $< > $@

$(LUAJIT_DEP):
	echo 'luajit_modified.o: luajit_modified.c lua.h luaconf.h lauxlib.h lualib.h luajit.h lj_arch.h' >>  $(LUAJIT_SRC_DIR)/Makefile.dep
	touch $(LUAJIT_DEP)

# 清理
clean:
	rm -f lua-cjson/lua_cjson_modified.c $(LUAJIT_MODIFIED_C) $(LUAJIT_DEP)
	sed -i '/luajit_modified.o: /d' $(LUAJIT_SRC_DIR)/Makefile.dep
	rm -f $(LIB_A) $(LIB_O) $(LUA_O) $(LUA_O:.o=.c)
	$(MAKE) -f Makefile -C luajit clean
