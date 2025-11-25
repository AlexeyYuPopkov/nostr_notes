// Условное подключение emscripten только при сборке для WASM
#ifdef EMSCRIPTEN
#include <emscripten.h>
#define KEEPALIVE EMSCRIPTEN_KEEPALIVE
#else
#define KEEPALIVE
#endif