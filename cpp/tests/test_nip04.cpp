#define CATCH_CONFIG_AES_256_CBC
#include <catch2/catch_test_macros.hpp>
#include <catch2/catch_approx.hpp>
#include <cstring>
#include <iostream>

#include <vector>
#include <string>
#include <cstring>

#include "secp_wrapper.h"
#include "nip04.h"
#include "tools.h"
#include "base64/base64.h"
#include "aes_256_cbc.h"



TEST_CASE("nip04decrypt buffer overwrite check", "[nip04decrypt]") {
    std::string privateKeyHex = "c1dc1680f11d179f15782461f32ef51498a7aa29812d841b0cb51e8bebd92ff9";
    std::string publicKeyHex = "02d0dd5814b6a15cb30d91153de389e5f2746517270b4472dccfb062a312eb4e4a";
    std::string iv = "gbRK9JayC/pMAeYdOmEApw==";
    std::string encrypted = "xFohe2OjSI0Y+WMa4ZvCkw==";
    std::string expected = "hello!";

    auto privateKeyBytes = hexStringToBytes(privateKeyHex);
    auto publicKeyBytes = hexStringToBytes(publicKeyHex);

    char *encryptedBase64Decoded = nullptr;
    char *base64DecodedIv = nullptr;

    size_t base64Len = base64_decode(encrypted.c_str(), encrypted.length(), &encryptedBase64Decoded);
    size_t base64IvLen = base64_decode(iv.c_str(), iv.length(), &base64DecodedIv);

    unsigned char *result = nullptr;

    std::vector<std::string> results;

    for (int i = 0; i < 5; ++i) {
        if (result) {
            free(result);
            result = nullptr;
        }

        unsigned int decryptedLen = nip04decrypt(
            privateKeyBytes.data(),
            publicKeyBytes.data(),
            (const unsigned char *)base64DecodedIv,
            (const unsigned char *)encryptedBase64Decoded,
            base64Len,
            &result);

        std::string resultStr(reinterpret_cast<char *>(result), decryptedLen);
        results.push_back(resultStr);

        std::cout << "[" << i << "] result len: " << decryptedLen << ", str: '" << resultStr << "'" << std::endl;

        REQUIRE(decryptedLen == expected.length());
        REQUIRE(resultStr == expected);
    }

    for (size_t i = 1; i < results.size(); ++i) {
        REQUIRE(results[i] == results[0]);  // Все результаты должны быть одинаковыми
    }

    if (result) {
        freeMemory(result);
    }

    free(encryptedBase64Decoded);
    free(base64DecodedIv);
}

TEST_CASE("nip04decrypt repeated call", "[nip04encrypt]") {
    std::string privateKeyHex = "c1dc1680f11d179f15782461f32ef51498a7aa29812d841b0cb51e8bebd92ff9";
    std::string publicKeyHex = "02d0dd5814b6a15cb30d91153de389e5f2746517270b4472dccfb062a312eb4e4a";
    std::string iv = "gbRK9JayC/pMAeYdOmEApw==";
    std::string encrypted = "xFohe2OjSI0Y+WMa4ZvCkw==";
    std::string expected = "hello!";

    auto privateKeyBytes = hexStringToBytes(privateKeyHex);
    auto publicKeyBytes = hexStringToBytes(publicKeyHex);

    char *encryptedBase64Decoded = nullptr;
    char *base64DecodedIv = nullptr;

    size_t base64Len = base64_decode(encrypted.c_str(), encrypted.length(), &encryptedBase64Decoded);
    size_t base64IvLen = base64_decode(iv.c_str(), iv.length(), &base64DecodedIv);

    // Два подряд вызова
    for (int i = 0; i < 5; ++i) {
        unsigned char *result = nullptr;

        unsigned int decryptedLen = nip04decrypt(
            privateKeyBytes.data(),
            publicKeyBytes.data(),
            (const unsigned char *)base64DecodedIv,
            (const unsigned char *)encryptedBase64Decoded,
            base64Len,
            &result);

        std::string resultStr = std::string(reinterpret_cast<char *>(result), decryptedLen);

        std::cout << "[" << i << "] decrypted length: " << decryptedLen << ", result: '" << resultStr << "'" << std::endl;

        REQUIRE(decryptedLen == expected.length());
        REQUIRE(resultStr == expected);

        if (result) {
            freeMemory(result);
        }
    }

    free(encryptedBase64Decoded);
    free(base64DecodedIv);
}

TEST_CASE("nip04decrypt", "[nip04encrypt]")
{
    // RU: Тестовые данные
    // EN: Test data
    std::string privateKeyHex = "c1dc1680f11d179f15782461f32ef51498a7aa29812d841b0cb51e8bebd92ff9";
    //  RU: добавили префикс 02 для сжатого ключа
    //  EN: added prefix 02 for compressed key
    std::string publicKeyHex = "02d0dd5814b6a15cb30d91153de389e5f2746517270b4472dccfb062a312eb4e4a";
    std::string iv = "gbRK9JayC/pMAeYdOmEApw==";
    std::string encrypted = "xFohe2OjSI0Y+WMa4ZvCkw==";
    std::string exepted = "hello!";

    auto privateKeyBytes = hexStringToBytes(privateKeyHex);
    auto publicKeyBytes = hexStringToBytes(publicKeyHex);

    // RU: Используем строку encrypted напрямую, а не пытаемся конвертировать из hex
    // EN: Use the encrypted string directly, not trying to convert from hex
    const unsigned char *encryptedBytes = (const unsigned char *)encrypted.c_str();
    const unsigned char *ivBytes = (const unsigned char *)iv.c_str();

    unsigned char *result = nullptr;

    char *encryptedBase64Decoded;
    char *base64DecodedIv;

    // size_t privateKeyBase64Len = base64_decode((const char *)encryptedBytes, encrypted.length(), &encryptedBase64Decoded);
    // size_t publicKeyBase64Len = base64_decode((const char *)ivBytes, iv.length(), &base64DecodedIv);

    size_t base64Len = base64_decode((const char *)encryptedBytes, encrypted.length(), &encryptedBase64Decoded);
    size_t base64IvLen = base64_decode((const char *)ivBytes, iv.length(), &base64DecodedIv);

    printAsBytes((unsigned char *)encryptedBase64Decoded, base64Len);

    unsigned int decryptedLen = nip04decrypt(
        privateKeyBytes.data(),
        publicKeyBytes.data(),
        (const unsigned char *)base64DecodedIv,
        (const unsigned char *)encryptedBase64Decoded,
        base64Len,
        &result);

    free(encryptedBase64Decoded);
    free(base64DecodedIv);

    SECTION("Compare result with expected")
    {
        printAsChars(result, decryptedLen);

        std::cout << "1:\t" << exepted << std::endl;
        std::string resultStr = std::string(reinterpret_cast<char *>(result), decryptedLen);
        std::cout << "2:\t" << resultStr << std::endl;
        REQUIRE(decryptedLen == exepted.length());
        REQUIRE(std::memcmp(result, exepted.c_str(), decryptedLen) == 0);
    }

    if (result)
    {
        freeMemory(result);
    }
}

TEST_CASE("nip04decryptOld", "[nip04decryptOld]")
{
    // RU: Тестовые данные
    // EN: Test data
    std::string privateKeyHex = "c1dc1680f11d179f15782461f32ef51498a7aa29812d841b0cb51e8bebd92ff9";
    //  RU: добавили префикс 02 для сжатого ключа
    //  EN: added prefix 02 for compressed key
    std::string publicKeyHex = "02d0dd5814b6a15cb30d91153de389e5f2746517270b4472dccfb062a312eb4e4a";
    std::string encrypted = "xFohe2OjSI0Y+WMa4ZvCkw==?iv=gbRK9JayC/pMAeYdOmEApw==";
    std::string exepted = "hello!";

    auto privateKeyBytes = hexStringToBytes(privateKeyHex);
    auto publicKeyBytes = hexStringToBytes(publicKeyHex);
    // RU: Используем строку encrypted напрямую, а не пытаемся конвертировать из hex
    // EN: Use the encrypted string directly, not trying to convert from hex
    const unsigned char *encryptedBytes = (const unsigned char *)encrypted.c_str();

    unsigned char *result = nullptr;

    unsigned int encryptedLen = nip04decryptOld(
        privateKeyBytes.data(),
        publicKeyBytes.data(),
        encryptedBytes,
        &result);

    // Print private key as bytes
    std::cout << "Private key bytes: " << std::endl;
    for (size_t i = 0; i < privateKeyBytes.size(); ++i)
    {
        printf("0x%02X ", privateKeyBytes[i]);
        if ((i + 1) % 8 == 0)
        {
            std::cout << std::endl;
        }
    }
    std::cout << std::endl;

    SECTION("Compare result with expected")
    {
        printAsChars(result, encryptedLen);

        std::cout << "1:\t" << exepted << std::endl;
        std::string resultStr = std::string(reinterpret_cast<char *>(result), encryptedLen);
        std::cout << "2:\t" << resultStr << std::endl;
        REQUIRE(encryptedLen == exepted.length());
        REQUIRE(std::memcmp(result, exepted.c_str(), encryptedLen) == 0); // сравниваем со строкой
    }

    if (result)
    {
        freeMemory(result);
    }
}

TEST_CASE("nip04encrypt + nip04decrypt", "[nip04encrypt]")
{
    // RU: Тестовые данные
    // EN: Test data
    std::string privateKeyHex = "c1dc1680f11d179f15782461f32ef51498a7aa29812d841b0cb51e8bebd92ff9";
    std::string publicKeyHex = "02d0dd5814b6a15cb30d91153de389e5f2746517270b4472dccfb062a312eb4e4a";

    auto privateKeyBytes = hexStringToBytes(privateKeyHex);
    auto publicKeyBytes = hexStringToBytes(publicKeyHex);

    std::string message = "Lorem ipsum dolor sit amet consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

    unsigned char *encrypted = nullptr;

    unsigned int encryptedLen = nip04encrypt(
        privateKeyBytes.data(),
        publicKeyBytes.data(),
        (const unsigned char *)message.c_str(),
        &encrypted);

    REQUIRE(encryptedLen > 0);
    REQUIRE(encrypted != nullptr);

    unsigned char *decrypted = nullptr;

    unsigned int decryptedLen = nip04decryptOld(
        privateKeyBytes.data(),
        publicKeyBytes.data(),
        encrypted,
        &decrypted);

    std::string decryptedStr = std::string(reinterpret_cast<char *>(decrypted), decryptedLen);

    SECTION("Compare result with expected")
    {
        REQUIRE(decryptedStr.length() == message.length());
        REQUIRE(strcmp(decryptedStr.c_str(), message.c_str()) == 0);
    }

    if (encrypted)
    {
        freeMemory(encrypted);
        freeMemory(decrypted);
    }
}
