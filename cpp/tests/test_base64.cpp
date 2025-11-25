#define CATCH_CONFIG_AES_256_CBC
#include <catch2/catch_test_macros.hpp>
#include <catch2/catch_approx.hpp>
#include <cstring>
#include <iostream>
#include <cstdio>

#include <vector>
#include <string>
#include <cstring>

#include "base64.h"

TEST_CASE("base64_encode simple", "[base64_encode]")
{
    const char *input = "Hello";
    char *encoded = nullptr;
    size_t encoded_len;

    encoded_len = base64_encode(input, strlen(input), &encoded);

    SECTION("Simple text encoding")
    {
        REQUIRE(encoded != nullptr);
        REQUIRE(encoded_len > 0);
        REQUIRE(strcmp(encoded, "SGVsbG8=") == 0);

        std::cout << "Input: " << input << std::endl;
        std::cout << "Base64: " << encoded << std::endl;
        std::cout << "Encoded length: " << encoded_len << std::endl;
    }

    if (encoded)
        free(encoded);
}

TEST_CASE("base64_encode_decode roundtrip", "[base64_encode]")
{
    const char *original = "Lorem ipsum dolor sit amet";
    char *encoded = nullptr;
    char *decoded = nullptr;
    size_t encoded_len, decoded_len;

    encoded_len = base64_encode(original, strlen(original), &encoded);
    decoded_len = base64_decode(encoded, encoded_len, &decoded);

    SECTION("Roundtrip encoding and decoding")
    {
        REQUIRE(encoded != nullptr);
        REQUIRE(decoded != nullptr);
        REQUIRE(encoded_len > 0);
        REQUIRE(decoded_len > 0);
        REQUIRE(decoded_len == strlen((const char *)original));
        REQUIRE(strcmp((const char *)decoded, (const char *)original) == 0);

        std::cout << "Original: " << original << std::endl;
        std::cout << "Original length: " << strlen((const char *)original) << std::endl;
        std::cout << "Encoded: " << encoded << std::endl;
        std::cout << "Encoded length: " << encoded_len << std::endl;
        std::cout << "Decoded: " << decoded << std::endl;
        std::cout << "Decoded length: " << decoded_len << std::endl;
    }

    if (encoded)
        free(encoded);
    if (decoded)
        free(decoded);
}