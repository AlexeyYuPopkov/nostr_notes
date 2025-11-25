

#ifndef SECP_WRAPPER
#define SECP_WRAPPER

#include <cstring>
#include <cstdlib>
// #include <cstdio>

extern "C"
{
    unsigned int deriveSharedKey(const unsigned char *privKey,
                                 const unsigned char *pubKey,
                                 unsigned char **result);
}

#endif