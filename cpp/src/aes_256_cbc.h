

#ifndef AES_256_CBC_H
#define AES_256_CBC_H

#include "flags.h"

#define AES256 1
extern "C"
{
#include "aes.h"
}

extern "C"
{
#include "aes.h"
}

extern "C"
{
    KEEPALIVE
    unsigned int
    encryptAes256Cbc(unsigned char *plaintext,
                     unsigned char *key,
                     unsigned char *iv,
                     unsigned char **result);

    KEEPALIVE
    unsigned int decryptAes256Cbc(const unsigned char *ciphertext,
                                  const unsigned char *key,
                                  const unsigned char *iv,
                                  unsigned char **result,
                                  int input_len);

    KEEPALIVE
    void freeMemory(unsigned char *ptr);
}

#endif