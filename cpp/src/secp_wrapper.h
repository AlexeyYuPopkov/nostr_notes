

#ifndef SECP_WRAPPER
#define SECP_WRAPPER

// #include <cstring>
// #include <cstdlib>

#ifdef __cplusplus
extern "C" {
#endif

    unsigned int deriveSharedKey(const unsigned char *privKey,
                                 const unsigned char *pubKey,
                                 unsigned char **result);
#ifdef __cplusplus
}
#endif

#endif