
// #include <iostream>
#include <cstring>

#include "nip04.h"
#include "secp_wrapper.h"
#include "aes_256_cbc.h"
#include "base64/base64.h"

unsigned int nip04encrypt(const unsigned char *privKey,
                          const unsigned char *pubKey,
                          const unsigned char *input,
                          unsigned char **result)
{
    // RU: Получаем общий секрет через deriveSharedKey
    // EN: Get the shared secret via deriveSharedKey
    unsigned char *sharedSecret;
    int sharedSecretLen = deriveSharedKey(privKey, pubKey, &sharedSecret);

    if (sharedSecretLen != 64) // deriveSharedKey возвращает 64 байта (x + y координаты)
    {
        return 0;
    }

    // RU: Используем первые 32 байта как ключ для AES256
    // EN: Use the first 32 bytes as the key for AES256
    unsigned char key[32];
    memcpy(key, sharedSecret, 32);

    // RU: Используем следующие 16 байт из второй половины как IV
    // EN: Use the next 16 bytes from the second half as IV
    unsigned char iv[16];
    // RU: Берем первые 16 байт из y-координаты
    // EN: Take the first 16 bytes from the y-coordinate
    memcpy(iv, sharedSecret + 32, 16);

    // RU: Шифруем input с помощью AES256 CBC
    // EN: Encrypt the input using AES256 CBC
    unsigned char *encrypted;
    size_t encryptedLen = encryptAes256Cbc((unsigned char *)input, key, iv, &encrypted);

    if (encryptedLen <= 0)
    {
        free(sharedSecret);
        return 0;
    }

    char *base64Encoded;
    char *base64Iv;

    size_t base64Len = base64_encode((const char *)encrypted, encryptedLen, &base64Encoded);
    size_t base64IvLen = base64_encode((const char *)iv, 16, &base64Iv);

    // RU: Выделяем память под финальный результат: encrypted + "?iv=" + 16 байт IV
    // EN: Allocate memory for the final result: encrypted + "?iv=" + 16 bytes of IV
    int totalLen = base64Len + 4 + base64IvLen;
    *result = (unsigned char *)malloc(totalLen);

    if (!*result)
    {
        free(sharedSecret);
        free(encrypted);
        return 0;
    }

    // RU: Копируем зашифрованные данные
    // EN: Copy the encrypted data
    memcpy(*result, base64Encoded, base64Len);

    // RU: Добавляем суффикс "?iv=" т.е. "0x3F, 0x69, 0x76, 0x3D"
    // EN: Add the suffix "?iv=" i.e. "0x3F, 0x69, 0x76, 0x3D"
    unsigned char suffix[4] = {0x3F, 0x69, 0x76, 0x3D};
    memcpy(*result + base64Len, suffix, 4);

    // RU: Копируем IV после cуффикса
    // EN: Copy IV after the suffix
    memcpy(*result + base64Len + 4, base64Iv, base64IvLen);

    // RU: Освобождаем временную память
    // EN: Free temporary memory
    free(base64Encoded);
    free(base64Iv);
    free(sharedSecret);
    free(encrypted);

    return totalLen;
}

unsigned int nip04decryptOld(const unsigned char *privKey,
                             const unsigned char *pubKey,
                             const unsigned char *input,
                             unsigned char **result)
{
    // 16 bytes of IV in base64 is 24 bytes
    const size_t ivLen = 16;
    const size_t base64IvLen = 24;
    const size_t suffixLen = 4;
    // RU: Поиск суффикса "?iv=" (4 байта)
    // EN: Search for the suffix "?iv=" (4 bytes)
    size_t inputLen = strlen(reinterpret_cast<const char *>(input));
    if (inputLen < 4 + base64IvLen)
    {
        return 0;
    }
    int suffixPos = inputLen - suffixLen - base64IvLen;
    if (suffixPos < 0)
    {
        return 0;
    }

    unsigned char suffix[4] = {0x3F, 0x69, 0x76, 0x3D}; // "?iv="
    // RU: Проверяем наличие суффикса
    // EN: Check for the presence of the suffix
    if (memcmp(input + suffixPos, suffix, suffixLen) != 0)
    {
        return 0;
    }

    char *ivBase64decoded = nullptr;
    size_t ivLength = base64_decode(
        (const char *)input + suffixPos + suffixLen,
        base64IvLen,
        &ivBase64decoded);

    char *contentBase64 = nullptr;
    size_t contentLength = base64_decode(
        (const char *)(input),
        suffixPos, // ← Декодируем только до позиции суффикса
        &contentBase64);

    // RU: Извлекаем IV из декодированных base64 данных
    // EN: Extract IV from decoded base64 data
    unsigned char iv[ivLen];
    if (ivLength >= ivLen)
    {
        memcpy(iv, (unsigned char *)ivBase64decoded, ivLen);
    }
    else
    {
        // Если декодированный IV меньше 16 байт, возвращаем ошибку
        free(ivBase64decoded);
        free(contentBase64);
        return 0;
    }

    free(ivBase64decoded);

    // Извлекаем зашифрованные данные
    int encryptedLen = contentLength; // Используем реальную длину декодированных данных
    unsigned char *encrypted = (unsigned char *)malloc(contentLength);
    if (!encrypted)
    {
        free(contentBase64);
        return 0;
    }
    memcpy(encrypted, (unsigned char *)contentBase64, contentLength); // Приведение типа

    free(contentBase64);

    // RU: Получаем общий секрет
    // EN: Get the shared secret
    unsigned char *sharedSecret = nullptr;
    int sharedSecretLen = deriveSharedKey(privKey, pubKey, &sharedSecret);
    if (sharedSecretLen != 64)
    {
        free(encrypted);
        if (sharedSecret)
        {
            // RU: Освобождаем память даже в случае ошибки
            // EN: Free memory even in case of error
            free(sharedSecret);
        }
        return 0;
    }

    // RU: Используем первые 32 байта как ключ для AES256-CBC
    // EN: Use the first 32 bytes as the key for AES256-CBC
    unsigned char key[32];
    memcpy(key, sharedSecret, 32);

    // RU: Дешифруем
    // EN: Decrypt
    // unsigned char *decrypted;
    int decryptedLen = decryptAes256Cbc(encrypted, key, iv, result, encryptedLen);

    free(sharedSecret);
    free(encrypted);

    if (decryptedLen <= 0)
    {
        return 0;
    }

    // *result = decrypted;
    return decryptedLen;
}

unsigned int nip04decryptOld1(const unsigned char *privKey,
                              const unsigned char *pubKey,
                              const unsigned char *iv,
                              const unsigned char *input,
                              unsigned char **result)
{

    const size_t kSharedSecretLen = 64;
    const size_t kAesCbcKeyLen = 32;
    const size_t kIvLength = 16;
    const size_t kBase64IvLength = 24;

    size_t inputLen = strlen(reinterpret_cast<const char *>(input));

    char *inputBase64Decoded = nullptr;
    size_t encryptedLen = base64_decode(
        (const char *)(input),
        inputLen,
        &inputBase64Decoded);

    unsigned char *encrypted = (unsigned char *)malloc(encryptedLen);
    if (!encrypted)
    {
        free(inputBase64Decoded);
        return 0;
    }

    memcpy(encrypted, (unsigned char *)inputBase64Decoded, encryptedLen);
    free(inputBase64Decoded);

    char *ivBase64decoded = nullptr;
    size_t ivLength = base64_decode(
        (const char *)iv,
        kBase64IvLength,
        &ivBase64decoded);

    if (ivLength != kIvLength)
    {
        free(ivBase64decoded);
        free(encrypted);
        return 0;
    }

    unsigned char *ivDecoded = (unsigned char *)malloc(kIvLength);
    memcpy(ivDecoded, (unsigned char *)ivBase64decoded, encryptedLen);
    free(ivBase64decoded);

    // RU: Получаем общий секрет
    // EN: Get the shared secret
    unsigned char *sharedSecret = nullptr;
    int sharedSecretLen = deriveSharedKey(privKey, pubKey, &sharedSecret);
    if (sharedSecretLen != kSharedSecretLen)
    {
        free(encrypted);
        if (sharedSecret)
        {
            // RU: Освобождаем память даже в случае ошибки
            // EN: Free memory even in case of error
            free(sharedSecret);
        }
        return 0;
    }

    // RU: Используем первые 32 байта как ключ для AES256-CBC
    // EN: Use the first 32 bytes as the key for AES256-CBC
    unsigned char key[kAesCbcKeyLen];
    memcpy(key, sharedSecret, kAesCbcKeyLen);

    // RU: Дешифруем
    // EN: Decrypt
    unsigned char *decrypted;
    int decryptedLen = decryptAes256Cbc(encrypted, key, ivDecoded, &decrypted, encryptedLen);

    free(sharedSecret);
    free(encrypted);

    if (decryptedLen <= 0)
    {
        return 0;
    }

    *result = decrypted;
    return decryptedLen;
}

unsigned int nip04decrypt(const unsigned char *privKey,
                          const unsigned char *pubKey,
                          const unsigned char *iv,
                          const unsigned char *input,
                          const size_t input_len,
                          unsigned char **result)
{

    const size_t kSharedSecretLen = 64;
    const size_t kAesCbcKeyLen = 32;
    const size_t kIvLength = 16;

    // size_t inputLen = strlen(reinterpret_cast<const char *>(input));

    // RU: Получаем общий секрет
    // EN: Get the shared secret
    unsigned char *sharedSecret = nullptr;
    int sharedSecretLen = deriveSharedKey(privKey, pubKey, &sharedSecret);
    if (sharedSecretLen != kSharedSecretLen)
    {
        if (sharedSecret)
        {
            // RU: Освобождаем память даже в случае ошибки
            // EN: Free memory even in case of error
            free(sharedSecret);
        }
        return 0;
    }

    // RU: Используем первые 32 байта как ключ для AES256-CBC
    // EN: Use the first 32 bytes as the key for AES256-CBC
    unsigned char key[kAesCbcKeyLen];
    memcpy(key, sharedSecret, kAesCbcKeyLen);
    free(sharedSecret);

    // // RU: Дешифруем
    // // EN: Decrypt
    unsigned char *decrypted;
    int decryptedLen = decryptAes256Cbc(input,
                                        key,
                                        iv,
                                        &decrypted,
                                        input_len);

    if (decryptedLen <= 0)
    {
        return 0;
    }

    // *result = decrypted;

    *result = (unsigned char *)malloc(decryptedLen);
    if (*result)
    {
        memcpy(*result, decrypted, decryptedLen);
    }
    return decryptedLen;
    // return strlen(reinterpret_cast<const char *>(*result));
}