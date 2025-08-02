#define CATCH_CONFIG_AES_256_CBC
#include <catch2/catch_test_macros.hpp>
#include <catch2/catch_approx.hpp>
#include <cstring>
#include <iostream>
#include <cstdio>

#include <vector>
#include <string>
#include <cstring>

#include "aes_256_cbc.h"

// cmake --build build
// ./build/test_aes_256_cbc

unsigned char iv[] = {
    0x58, 0x9C, 0xE2, 0x3B, 0x21, 0x37, 0x39, 0x5C,
    0x7E, 0x94, 0xDA, 0xCF, 0x9F, 0x24, 0xA8, 0xCF};
unsigned char key[] = {
    0x20, 0xC4, 0xCF, 0x63, 0x45, 0xFC, 0xFD, 0x67,
    0x9F, 0xF5, 0x7B, 0x95, 0xE1, 0x72, 0x72, 0x80,
    0x26, 0x66, 0x53, 0xCA, 0xEE, 0xA2, 0x54, 0x88,
    0x59, 0x05, 0xE4, 0x35, 0x76, 0x12, 0xFA, 0x99};

unsigned char ciphertext[] = {
    0x78, 0x5F, 0xB6, 0xA6, 0x32, 0x84, 0xD3, 0x7F,
    0x9C, 0xBE, 0x49, 0x01, 0xD4, 0x08, 0xBB, 0x6B,
    0xD6, 0x4E, 0x30, 0x68, 0x98, 0x5A, 0xBB, 0xDF,
    0x98, 0x9B, 0x70, 0x64, 0x55, 0xFA, 0x9B, 0xB6,
    0xB8, 0x74, 0x2A, 0x18, 0x8F, 0x30, 0x02, 0x23,
    0x48, 0x9A, 0xA9, 0x71, 0x81, 0x81, 0x9C, 0x4C,
    0xE5, 0x18, 0x5D, 0xD0, 0x91, 0xE1, 0xB7, 0x06,
    0x41, 0x66, 0xFF, 0x34, 0x99, 0xD3, 0x2E, 0xF5,
    0xD7, 0xEB, 0x65, 0x7A, 0x2A, 0x0E, 0x37, 0xB3,
    0x96, 0xAD, 0xC7, 0xC3, 0x3E, 0xD2, 0x9D, 0xAD,
    0x20, 0x34, 0xD8, 0xC6, 0xCE, 0x5C, 0xEF, 0x10,
    0x7E, 0x81, 0x87, 0x30, 0xB3, 0x9D, 0xAF, 0x05,
    0x69, 0x66, 0xAE, 0xBB, 0x00, 0xEC, 0xE1, 0xDD,
    0xA0, 0xE7, 0x92, 0x1D, 0x56, 0xCD, 0x98, 0xC0,
    0xE8, 0x91, 0x57, 0x01, 0xB8, 0xFD, 0x50, 0x2E,
    0x60, 0xB6, 0xC5, 0xB2, 0xD8, 0x22, 0xE9, 0x35};

TEST_CASE("Decryption AES 256 CBC tests", "[decryptAes256Cbc]")
{
    std::string expected = "Lorem ipsum dolor sit amet consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

    unsigned char *plaintext;
    size_t cipherTextLen = sizeof(ciphertext) / sizeof(ciphertext[0]);

    std::cout << std::string(reinterpret_cast<char *>(ciphertext), cipherTextLen) << std::endl;

    unsigned int plaintextLen = decryptAes256Cbc(ciphertext, key, iv, &plaintext, cipherTextLen);

    // std::string adjustedPlaintext = std::string(reinterpret_cast<char *>(plaintext), plaintextLen);

    SECTION("Decryption AES 256 CBC")
    {
        REQUIRE(std::string(reinterpret_cast<char *>(plaintext), plaintextLen) == expected);
    }

    freeMemory(plaintext);
}

TEST_CASE("Encryption AES 256 CBC tests", "[encryptAes256Cbc]")
{
    std::string plaintext = "Lorem ipsum dolor sit amet consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

    unsigned char *ciphertext_chars;
    unsigned char *plaintext_chars = reinterpret_cast<unsigned char *>(const_cast<char *>(plaintext.c_str()));
    unsigned int ciphertextLen = encryptAes256Cbc(plaintext_chars, key, iv, &ciphertext_chars);

    SECTION("Encryption AES 256 CBC")
    {
        REQUIRE(ciphertextLen == sizeof(ciphertext));
        REQUIRE(std::memcmp(ciphertext_chars, ciphertext, ciphertextLen) == 0);
    }

    freeMemory(ciphertext_chars);
}

TEST_CASE("Encryption Then Decryption AES 256 CBC tests", "[encryptAes256Cbc, decryptAes256Cbc]")
{
    std::string plaintext = "Lorem ipsum dolor sit amet consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    unsigned char *ciphertext_chars;
    unsigned char *plaintext_chars = reinterpret_cast<unsigned char *>(const_cast<char *>(plaintext.c_str()));
    unsigned int ciphertextLen = encryptAes256Cbc(plaintext_chars, key, iv, &ciphertext_chars);

    unsigned char *decrypted_chars;
    unsigned int decryptedLen = decryptAes256Cbc(ciphertext_chars, key, iv, &decrypted_chars, ciphertextLen);

    SECTION("Encryption followed by Decryption returns original plaintext")
    {
        REQUIRE(decryptedLen == plaintext.size());
        REQUIRE(std::string(reinterpret_cast<char *>(decrypted_chars), decryptedLen) == plaintext);
    }

    SECTION("Encryption output matches expected ciphertext")
    {
        REQUIRE(ciphertextLen == sizeof(ciphertext));
        REQUIRE(std::memcmp(ciphertext_chars, ciphertext, ciphertextLen) == 0);
    }

    SECTION("Decryption of expected ciphertext returns original plaintext")
    {
        unsigned char *decrypted_from_expected;
        unsigned int len = decryptAes256Cbc(ciphertext, key, iv, &decrypted_from_expected, sizeof(ciphertext));
        REQUIRE(std::string(reinterpret_cast<char *>(decrypted_from_expected), len) == plaintext);
        freeMemory(decrypted_from_expected);
    }

    freeMemory(ciphertext_chars);
    freeMemory(decrypted_chars);
}