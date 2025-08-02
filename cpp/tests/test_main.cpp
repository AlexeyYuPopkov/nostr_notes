#define CATCH_CONFIG_MAIN
#include <catch2/catch_test_macros.hpp>
#include <catch2/catch_approx.hpp>
#include <cstring>

#include "aes_256_cbc.h"

TEST_CASE("someFunction tests", "[someFunction]") {
    SECTION("Test with positive number") {
        REQUIRE(someFunction(2.0) == Catch::Approx(4.0));
    }
}
