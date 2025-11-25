#include "secp_wrapper.h"

// Implementation uses secp256k1 for ECDH key agreement.
#include <secp256k1.h>
#include <secp256k1_ecdh.h>
#include <cstring>

unsigned int deriveSharedKey(const unsigned char *privKey,
                             const unsigned char *pubKey,
                             unsigned char **result)
{
    secp256k1_context *ctx = secp256k1_context_create(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY);
    if (!ctx)
    {
        return -1;
    }

    secp256k1_pubkey pubkey;
    if (!secp256k1_ec_pubkey_parse(ctx, &pubkey, pubKey, 33))
    {
        secp256k1_context_destroy(ctx);
        return -1;
    }

    // Выполняем скалярное умножение: shared_point = privKey * pubKey
    secp256k1_pubkey shared_point = pubkey;
    if (!secp256k1_ec_pubkey_tweak_mul(ctx, &shared_point, privKey))
    {
        secp256k1_context_destroy(ctx);
        return -1;
    }

    // Сериализуем результат в несжатый формат (65 байт: 0x04 + x + y)
    unsigned char full_point[65];
    size_t output_len = 65;
    secp256k1_ec_pubkey_serialize(ctx, full_point, &output_len, &shared_point, SECP256K1_EC_UNCOMPRESSED);

    *result = (unsigned char *)malloc(64);
    if (!*result)
    {
        secp256k1_context_destroy(ctx);
        return -1;
    }

    // Копируем x + y координаты (пропускаем первый байт 0x04)
    memcpy(*result, full_point + 1, 64);

    secp256k1_context_destroy(ctx);
    return 64; // Возвращаем 64 байта (32 байта x + 32 байта y)
}