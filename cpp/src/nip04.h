

#ifndef NIP_04
#define NIP_04

#include "flags.h"

extern "C"
{
    KEEPALIVE
    unsigned int nip04encrypt(const unsigned char *privKey,
                              const unsigned char *pubKey,
                              const unsigned char *input,
                              unsigned char **result);

    KEEPALIVE
    unsigned int nip04decryptOld(const unsigned char *privKey,
                                 const unsigned char *pubKey,
                                 const unsigned char *input,
                                 unsigned char **result);

    KEEPALIVE
    unsigned int nip04decrypt(const unsigned char *privKey,
                              const unsigned char *pubKey,
                              const unsigned char *iv,
                              const unsigned char *input,
                              const size_t input_len,
                              unsigned char **result);
}

#endif