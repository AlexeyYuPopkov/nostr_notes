
#include "aes_256_cbc.h"
#include "aes.h"
#include <cstring>
#include <cstdlib>
#include <cstdio>

// 256-bit = 32 bytes
#define KEY_SIZE 32
#define IV_SIZE 16
#define BLOCK_SIZE 16
#define AES256 1 
double someFunction(double params)
{
    return params * 2;
}

unsigned int encryptAes256Cbc(unsigned char *plaintext,
                              unsigned char *key,
                              unsigned char *iv,
                              unsigned char **result)
{
    int len = strlen(reinterpret_cast<const char *>(plaintext));
    int padded_len = ((len / BLOCK_SIZE) + 1) * BLOCK_SIZE;

    // Выделяем память для результата
    *result = (unsigned char *)malloc(padded_len);
    if (*result == nullptr)
    {
        return 0;
    }

    // Копируем данные и добавляем PKCS7 padding
    memcpy(*result, plaintext, len);

    // PKCS7 padding
    int padding = padded_len - len;
    for (int i = len; i < padded_len; i++)
    {
        (*result)[i] = padding;
    }

    // Инициализируем AES контекст
    struct AES_ctx ctx;
    AES_init_ctx_iv(&ctx, key, iv);

    // Шифруем
    AES_CBC_encrypt_buffer(&ctx, *result, padded_len);

    return padded_len;
}

unsigned int decryptAes256Cbc(unsigned char *ciphertext,
                              unsigned char *key,
                              unsigned char *iv,
                              unsigned char **result,
                              int ciphertext_len)
{
    // Выделяем память для результата
    *result = (unsigned char *)malloc(ciphertext_len);
    if (*result == nullptr) {
        return 0;
    }

    // Копируем зашифрованные данные в результат
    memcpy(*result, ciphertext, ciphertext_len);

    // Инициализируем AES контекст
    struct AES_ctx ctx;
    AES_init_ctx_iv(&ctx, key, iv);

    // Расшифровываем данные
    AES_CBC_decrypt_buffer(&ctx, *result, ciphertext_len);

    // Remove PKCS7 padding
    if (ciphertext_len > 0) {
        int padding = (*result)[ciphertext_len - 1];
        if (padding > 0 && padding <= BLOCK_SIZE) {
            // Check all padding bytes
            bool valid = true;
            for (int i = ciphertext_len - padding; i < ciphertext_len; ++i) {
                if ((*result)[i] != padding) {
                    valid = false;
                    break;
                }
            }
            if (valid) {
                ciphertext_len -= padding;
            }
        }
    }

    return ciphertext_len;
}

void freeMemory(unsigned char* ptr) {
    if (ptr != nullptr) {
        free(ptr);
    }
}
