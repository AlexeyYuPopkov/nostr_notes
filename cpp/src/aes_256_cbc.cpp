#include "aes_256_cbc.h"
#include "aes.h"
// #include <cstring>
#include <cstdlib>
#include <cstdio>
// #include <iostream>
// #include <sstream>
#include "tools.h"

// 256-bit = 32 bytes
#define KEY_SIZE 32
#define IV_SIZE 16
#define BLOCK_SIZE 16
#define AES256 1

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

unsigned int decryptAes256Cbc(const unsigned char *ciphertext,
                              const unsigned char *key,
                              const unsigned char *iv,
                              unsigned char **result,
                              int input_len)
{
    int output_Len = input_len;
    // Allocate zero-initialized memory for the result
    unsigned char *plaintext = (unsigned char *)calloc(output_Len, 1);
    if (plaintext == nullptr)
    {
        return 0;
    }

    // Copy ciphertext to result buffer
    memcpy(plaintext, ciphertext, input_len);

    // Инициализируем AES контекст
    struct AES_ctx ctx;
    AES_init_ctx_iv(&ctx, key, iv);

    // Расшифровываем данные
    AES_CBC_decrypt_buffer(&ctx, plaintext, input_len);

    // Remove PKCS7 padding and clear sensitive data
    if (output_Len > 0)
    {
        int padding = plaintext[output_Len - 1];
        if (padding > 0 && padding <= BLOCK_SIZE)
        {
            // Check all padding bytes (optional, for strict validation)
            bool valid = true;
            for (int i = output_Len - padding; i < output_Len; ++i)
            {
                if (plaintext[i] != padding)
                {
                    valid = false;
                    break;
                }
            }
            if (valid)
            {
                output_Len -= padding;
                memset(plaintext + output_Len, 0, padding);
            }
        }
    }

    *result = plaintext;
    return output_Len;
}

void freeMemory(unsigned char *ptr)
{
    if (ptr != nullptr)
    {
        free(ptr);
    }
}
