#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>

void registerSo(lua_State *L, const char *name, lua_CFunction f) {
    // 获取 package 表
    lua_getglobal(L, "package");
    if (lua_istable(L, -1)) {
        // 获取 package.preload 表
        lua_getfield(L, -1, "preload");
        if (lua_istable(L, -1)) {
            // 将加载函数推入栈
            lua_pushcfunction(L, f);
            // 将加载函数存储到 package.preload 表中
            lua_setfield(L, -2, name);
        }
        lua_pop(L, 1); // 弹出 package.preload 表
    }
    lua_pop(L, 1); // 弹出 package 表
}

void registerLua(lua_State *L,  const char *name, const unsigned char *code, size_t length) {
    // 加载 Lua 代码
    if (luaL_loadbuffer(L, code, length, name) == 0) {
        // 将加载函数存储到 package.preload 表中
        lua_getglobal(L, "package");
        lua_getfield(L, -1, "preload");
        lua_pushvalue(L, -3); // 复制加载函数
        lua_setfield(L, -2, name); // 注册到 package.preload
        lua_pop(L, 2); // 弹出 package 和 package.preload 表
    } else {
        fprintf(stderr, "Failed to load Lua code for module '%s'\n", name);
    }
}



extern int luaopen_cjson(lua_State *l);

extern int luaopen_socket_core(lua_State *L);
extern int luaopen_mime_core(lua_State *L);
#if defined(__linux__) || defined(__APPLE__)
    extern int luaopen_socket_unix(lua_State *L);
    extern int luaopen_socket_serial(lua_State *L)
#endif
extern unsigned char luasocket_src_ltn12_lua[];
extern unsigned int luasocket_src_ltn12_lua_len;
extern unsigned char luasocket_src_socket_lua[];
extern unsigned int luasocket_src_socket_lua_len;
extern unsigned char luasocket_src_mime_lua[];
extern unsigned int luasocket_src_mime_lua_len;
extern unsigned char luasocket_src_headers_lua[];
extern unsigned int luasocket_src_headers_lua_len;
extern unsigned int luasocket_src_mime_lua_len;
extern unsigned char luasocket_src_http_lua[];
extern unsigned int luasocket_src_http_lua_len;
extern unsigned char luasocket_src_url_lua[];
extern unsigned int luasocket_src_url_lua_len;
extern unsigned char luasocket_src_ftp_lua[];
extern unsigned int luasocket_src_ftp_lua_len;
extern unsigned char luasocket_src_smtp_lua[];
extern unsigned int luasocket_src_smtp_lua_len;
extern unsigned char luasocket_src_tp_lua[];
extern unsigned int luasocket_src_tp_lua_len;

extern int luaopen_ssl_config(lua_State *L);
extern int luaopen_ssl_context(lua_State *L);
extern int luaopen_ssl_core(lua_State *L);
extern int luaopen_ssl_x509(lua_State *L);
extern unsigned char luasec_src_https_lua[];
extern unsigned int luasec_src_https_lua_len;
extern unsigned char luasec_src_ssl_lua[];
extern unsigned int luasec_src_ssl_lua_len;

extern int luaopen_pb_io(lua_State *L);
extern int luaopen_pb_conv(lua_State *L);
extern int luaopen_pb_buffer(lua_State *L);
extern int luaopen_pb_slice(lua_State *L);
extern int luaopen_pb(lua_State *L);
extern int luaopen_pb_unsafe(lua_State *L);
extern unsigned char lua_protobuf_protoc_lua[];
extern unsigned int lua_protobuf_protoc_lua_len;

extern int luaopen_openssl(lua_State*L);


extern unsigned char inspect_lua_inspect_lua[];
extern unsigned int inspect_lua_inspect_lua_len;

extern unsigned char serpent_src_serpent_lua[];
extern unsigned int serpent_src_serpent_lua_len;

void register3rdModules(lua_State *L)
{
  registerSo(L, "cjson", luaopen_cjson);
  registerSo(L, "socket.core", luaopen_socket_core);
  registerSo(L, "mime.core", luaopen_mime_core);
  #if defined(__linux__) || defined(__APPLE__)
    registerSo(L, "socket.unix", luaopen_socket_unix);
    registerSo(L, "socket.serial", luaopen_socket_serial);
  #endif

  registerLua(L, "ltn12", luasocket_src_ltn12_lua, luasocket_src_ltn12_lua_len);
  registerLua(L, "socket", luasocket_src_socket_lua, luasocket_src_socket_lua_len);
  registerLua(L, "mime", luasocket_src_mime_lua, luasocket_src_mime_lua_len);
  registerLua(L, "socket.headers", luasocket_src_headers_lua, luasocket_src_headers_lua_len);
  registerLua(L, "socket.http", luasocket_src_http_lua, luasocket_src_http_lua_len);
  registerLua(L, "socket.url", luasocket_src_url_lua, luasocket_src_url_lua_len);
  registerLua(L, "socket.ftp", luasocket_src_ftp_lua, luasocket_src_ftp_lua_len);
  registerLua(L, "socket.smtp", luasocket_src_smtp_lua, luasocket_src_smtp_lua_len);
  registerLua(L, "socket.tp", luasocket_src_tp_lua, luasocket_src_tp_lua_len);

  registerSo(L, "ssl.config", luaopen_ssl_config);
  registerSo(L, "ssl.context", luaopen_ssl_context);
  registerSo(L, "ssl.core", luaopen_ssl_core);
  registerSo(L, "ssl.x509", luaopen_ssl_x509);
  registerLua(L, "ssl.https", luasec_src_https_lua, luasec_src_https_lua_len);
  registerLua(L, "ssl", luasec_src_ssl_lua, luasec_src_ssl_lua_len);


  registerSo(L, "pb.io", luaopen_pb_io);
  registerSo(L, "pb.conv", luaopen_pb_conv);
  registerSo(L, "pb.buffer", luaopen_pb_buffer);
  registerSo(L, "pb.slice", luaopen_pb_slice);
  registerSo(L, "pb", luaopen_pb);
  registerSo(L, "pb.unsafe", luaopen_pb_unsafe);
  registerLua(L, "protoc", lua_protobuf_protoc_lua, lua_protobuf_protoc_lua_len);

  registerSo(L, "openssl", luaopen_openssl);

  registerLua(L, "inspect", inspect_lua_inspect_lua, inspect_lua_inspect_lua_len);

  registerLua(L, "serpent", serpent_src_serpent_lua, serpent_src_serpent_lua_len);
}
