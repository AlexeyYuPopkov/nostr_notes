#ifndef AES_256_CBC_H
#define AES_256_CBC_H
#define AES256 1 
extern "C"
{
#include "aes.h"
}

// Условное подключение emscripten только при сборке для WASM
#ifdef EMSCRIPTEN
#include <emscripten.h>
#define KEEPALIVE EMSCRIPTEN_KEEPALIVE
#else
#define KEEPALIVE
#endif

extern "C"
{
#include "aes.h"
}

extern "C"
{
    KEEPALIVE
    double someFunction(double params);

    KEEPALIVE // Функции возвращают длину и принимают указатель на результат
        unsigned int
        encryptAes256Cbc(unsigned char *plaintext,
                         unsigned char *key,
                         unsigned char *iv,
                         unsigned char **result);

    KEEPALIVE
    unsigned int decryptAes256Cbc(unsigned char *ciphertext,
                                  unsigned char *key,
                                  unsigned char *iv,
                                  unsigned char **result, int ciphertext_len);

    KEEPALIVE
    void freeMemory(unsigned char *ptr);
}

#endif