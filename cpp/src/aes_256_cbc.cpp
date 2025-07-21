
#include "aes_256_cbc.h"
#include "aes.h"
#include <cstring>
#include <cstdlib>
// #include <stdio.h>

// 256-bit = 32 bytes
#define KEY_SIZE 32
#define IV_SIZE 16
#define BLOCK_SIZE 16

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
                              unsigned char **result, int ciphertext_len)
{
    // // Для простоты предполагаем стандартный размер блока
    // // int ciphertext_len = 48; // Должно быть кратно 16

    // // Выделяем память для результата
    // *result = (unsigned char *)malloc(ciphertext_len + 1);
    // if (*result == nullptr)
    // {
    //     return 0;
    // }

    // memcpy(*result, ciphertext, ciphertext_len);

    // // Инициализируем AES контекст
    // struct AES_ctx ctx;
    // AES_init_ctx_iv(&ctx, key, iv);

    // // Расшифровываем
    // AES_CBC_decrypt_buffer(&ctx, *result, ciphertext_len);

    // // Убираем PKCS7 padding
    // int padding = (*result)[ciphertext_len - 1];
    // int actual_len = ciphertext_len;

    // if (padding > 0 && padding <= BLOCK_SIZE)
    // {
    //     actual_len = ciphertext_len - padding;
    //     (*result)[actual_len] = '\0';
    // }
    // else
    // {
    //     (*result)[ciphertext_len] = '\0';
    // }

    // return actual_len;

   // Отладочная информация
    // printf("C++: Decrypt called with ciphertext_len=%d\n", ciphertext_len);
    // printf("C++: First 10 ciphertext bytes: ");
    // for(int i = 0; i < 10 && i < ciphertext_len; i++) {
    //     printf("%02x ", ciphertext[i]);
    // }
    // printf("\n");
    
    // printf("C++: Key: ");
    // for(int i = 0; i < 32; i++) {
    //     printf("%02x ", key[i]);
    // }
    // printf("\n");
    
    // printf("C++: IV: ");
    // for(int i = 0; i < 16; i++) {
    //     printf("%02x ", iv[i]);
    // }
    // printf("\n");

    // Проверяем входные данные
    // if (!ciphertext || !key || !iv || !result || ciphertext_len <= 0) {
    //     printf("C++: Invalid input parameters\n");
    //     return 0;
    // }
    
    // if (ciphertext_len % 16 != 0) {
    //     printf("C++: Ciphertext length not multiple of 16: %d\n", ciphertext_len);
    //     return 0;
    // }

    // Выделяем память для результата
    *result = (unsigned char *)malloc(ciphertext_len);
    // if (*result == nullptr) {
    //     printf("C++: Failed to allocate memory\n");
    //     return 0;
    // }

    // Копируем ciphertext в result
    memcpy(*result, ciphertext, ciphertext_len);
    
    // printf("C++: Memory allocated and data copied\n");

    // Инициализируем AES контекст
    struct AES_ctx ctx;
    AES_init_ctx_iv(&ctx, key, iv);
    
    // printf("C++: AES context initialized\n");

    // Дешифруем IN-PLACE
    AES_CBC_decrypt_buffer(&ctx, *result, ciphertext_len);
    
    // printf("C++: Decryption completed\n");
    // printf("C++: First 10 decrypted bytes: ");
    // for(int i = 0; i < 10 && i < ciphertext_len; i++) {
    //     printf("%02x ", (*result)[i]);
    // }
    // printf("\n");
    
    // printf("C++: Last 10 decrypted bytes: ");
    // for(int i = ciphertext_len - 10; i < ciphertext_len; i++) {
    //     printf("%02x ", (*result)[i]);
    // }
    // printf("\n");

    return ciphertext_len;
}

void freeMemory(unsigned char *ptr)
{
    free(ptr);
}

// #include <openssl/conf.h>
// #include <openssl/evp.h>
// #include <openssl/err.h>
// #include <string.h>

// #include "aes_256_cbc.h"

// void handleErrors(void)
// {
//     // ERR_print_errors_fp(stderr);
//     // std::cout << "An error occurred in OpenSSL." << std::endl;
//     abort();
// }

// Aes256CbcEncryptor::Aes256CbcEncryptor(unsigned char *key, unsigned char *iv, unsigned char *plaintext)
// {
//     this->key = key;
//     this->iv = iv;
//     this->plaintext = plaintext;
//     plaintext_len = strlen((const char *)plaintext);
//     int ciphertext_len = plaintext_len + 16; // запас для padding (например, AES block size)
//     this->ciphertext = new unsigned char[ciphertext_len];
// }

// unsigned char *Aes256CbcEncryptor::encrypt()
// {
//     EVP_CIPHER_CTX *ctx;

//     int len;

//     int ciphertext_len;

//     /* Create and initialise the context */
//     if (!(ctx = EVP_CIPHER_CTX_new()))
//         handleErrors();

//     /* Initialise the encryption operation */
//     if (1 != EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv))
//         handleErrors();

//     /* Provide the message to be encrypted */
//     if (1 != EVP_EncryptUpdate(ctx, ciphertext, &len, plaintext, plaintext_len))
//         handleErrors();
//     ciphertext_len = len;

//     /* Finalise the encryption */
//     if (1 != EVP_EncryptFinal_ex(ctx, ciphertext + len, &len))
//         handleErrors();
//     ciphertext_len += len;

//     /* Clean up */
//     EVP_CIPHER_CTX_free(ctx);

//     return ciphertext;
// }

// Aes256CbcDecryptor::Aes256CbcDecryptor(unsigned char *key, unsigned char *iv, unsigned char *ciphertext)
// {
//     this->key = key;
//     this->iv = iv;
//     this->ciphertext = ciphertext;
//     ciphertext_len = strlen((const char *)ciphertext);
//     this->plaintext = new unsigned char[ciphertext_len];
// }

// unsigned char *Aes256CbcDecryptor::decrypt()
// {
//     EVP_CIPHER_CTX *ctx;

//     int len;

//     int plaintext_len;

//     /* Create and initialise the context */
//     if (!(ctx = EVP_CIPHER_CTX_new()))
//         handleErrors();

//     /*
//      * Initialise the decryption operation. IMPORTANT - ensure you use a key
//      * and IV size appropriate for your cipher
//      * In this example we are using 256 bit AES (i.e. a 256 bit key). The
//      * IV size for *most* modes is the same as the block size. For AES this
//      * is 128 bits
//      */
//     if (1 != EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv))
//         handleErrors();

//     /*
//      * Provide the message to be decrypted, and obtain the plaintext output.
//      * EVP_DecryptUpdate can be called multiple times if necessary.
//      */
//     if (1 != EVP_DecryptUpdate(ctx, plaintext, &len, ciphertext, ciphertext_len))
//         handleErrors();
//     plaintext_len = len;

//     /*
//      * Finalise the decryption. Further plaintext bytes may be written at
//      * this stage.
//      */
//     if (1 != EVP_DecryptFinal_ex(ctx, plaintext + len, &len))
//         handleErrors();
//     plaintext_len += len;

//     /* Clean up */
//     EVP_CIPHER_CTX_free(ctx);

//     return plaintext;
// }

// // extern "C"
// // {
// double someFunction(double params)
// {
//     return params * 2;
// }
// // https://wiki.openssl.org/index.php/EVP_Symmetric_Encryption_and_Decryption
// unsigned char *encryptAes256Cbc(unsigned char *plaintext,
//                                  unsigned char *key,
//                                  unsigned char *iv)
// {
//     Aes256CbcEncryptor encryptor(key, iv, plaintext);
//     unsigned char *result = encryptor.encrypt();
//     return result;
// }

// unsigned char *decryptAes256Cbc(unsigned char *ciphertext,
//                                  unsigned char *key,
//                                  unsigned char *iv)
// {
//     Aes256CbcDecryptor decryptor(key, iv, ciphertext);
//     unsigned char *result = decryptor.decrypt();
//     return result;
// }
// // }