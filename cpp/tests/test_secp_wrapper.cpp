#define CATCH_CONFIG_AES_256_CBC
#include <catch2/catch_test_macros.hpp>
#include <catch2/catch_approx.hpp>
#include <cstring>
#include <iostream>
#include <cstdio>

#include <vector>
#include <string>
#include <cstring>

#include "secp_wrapper.h"
#include "tools.h"

TEST_CASE("deriveSharedKey", "[deriveSharedKey]")
{
    unsigned char exepted[32] = {
        0x42, 0x9A, 0x6D, 0x28, 0x0D, 0x66, 0x83, 0x08,
        0xE4, 0x47, 0x82, 0x61, 0x35, 0xE3, 0xE9, 0x4A,
        0x44, 0xB6, 0x04, 0x17, 0x23, 0x49, 0xF2, 0x42,
        0xBB, 0xC3, 0xBE, 0x1C, 0x67, 0xD2, 0x2B, 0xC5};
        

            unsigned char exeptedIv[8] = {
        0xC1, 0xAA, 0xB4, 0xFA, 0x08, 0x1F, 0xE4, 0xF7};

    std::string privateKeyHex = "c1dc1680f11d179f15782461f32ef51498a7aa29812d841b0cb51e8bebd92ff9";
    /// [publicKeyHex] prefix 02 - compression flag
    std::string publicKeyHex = "02d0dd5814b6a15cb30d91153de389e5f2746517270b4472dccfb062a312eb4e4a";

    // std::cout << "Private Key: ";
    // printHex(hexStringToBytes(privateKeyHex).data(), 32);
    // std::cout << "Public Key: ";
    // printHex(hexStringToBytes(publicKeyHex).data(), 32);

    unsigned char *result;
    auto len = deriveSharedKey(
        hexStringToBytes(privateKeyHex).data(),
        hexStringToBytes(publicKeyHex).data(),
        &result);

    std::cout << "Full shared secret length: " << len << std::endl;
    std::cout << "Full shared secret: ";
    printAsChars(result, len);

    // Извлекаем key и iv как в Kepler.byteSecret
    unsigned char key[32];
    unsigned char iv[8];

    if (len >= 64)
    {
        memcpy(key, result, 32);    // первые 32 байта (X) → key
        memcpy(iv, result + 32, 8); // следующие 8 байт (часть Y) → iv

        std::cout << "Key (32 bytes): ";
        printAsChars(key, 32);

        std::cout << "IV (8 bytes): ";
        printAsChars(iv, 16);
    }

    SECTION("deriveSharedKey")
    {
        REQUIRE(len == 64); // Полная точка должна быть 64 байта (x + y)
        REQUIRE(result != nullptr);

        REQUIRE(memcmp(key, exepted, 32) == 0);
        // TODO: проверить iv
        REQUIRE(memcmp(iv, exeptedIv, 8) == 0);
    }

    if (result)
    {
        free(result); // Use free instead of delete[] since malloc was used
    }
}
