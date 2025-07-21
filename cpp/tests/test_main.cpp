#define CATCH_CONFIG_MAIN
#include <catch2/catch_test_macros.hpp>
#include <catch2/catch_approx.hpp>
#include <cstring>

#include "aes_256_cbc.h"

TEST_CASE("someFunction tests", "[someFunction]") {
    
    SECTION("Test with positive number") {
        REQUIRE(someFunction(2.0) == Catch::Approx(4.0));
    }
    
    SECTION("Test with zero") {
        REQUIRE(someFunction(0.0) == Catch::Approx(0.0));
    }
    
    SECTION("Test with negative number") {
        REQUIRE(someFunction(-3.5) == Catch::Approx(-7.0));
    }
    
    SECTION("Test with large number") {
        REQUIRE(someFunction(1e6) == Catch::Approx(2e6));
    }
    
    SECTION("Test with small number") {
        REQUIRE(someFunction(1e-6) == Catch::Approx(2e-6));
    }

    // SECTION("method interface") {
    //     const char *result = encryptNip04("privateKey", "publicKey", "userId");
    //     // REQUIRE(strcmp(result, "Hello from C!") == 0);
    //     REQUIRE(std::string(result) == "Hello from C!");
    //     // free((void*)result);
    // }
}
