#include "ExampleMultiplier.h"
#include <catch2/catch_test_macros.hpp>

TEST_CASE("ExampleMultiplier multiplies two numbers correctly", "[ExampleMultiplier]")
{
    ExampleMultiplier multiplier;

    SECTION("Multiplying positive numbers")
    {
        multiplier.multiply(3, 4);
        REQUIRE(multiplier.result() == 12);
    }

    SECTION("Multiplying a positive and a negative number")
    {
        multiplier.multiply(-2, 5);
        REQUIRE(multiplier.result() == -10);
    }

    SECTION("Multiplying two negative numbers")
    {
        multiplier.multiply(-3, -4);
        REQUIRE(multiplier.result() == 12);
    }

    SECTION("Multiplying by zero")
    {
        multiplier.multiply(0, 5);
        REQUIRE(multiplier.result() == 0);
    }
}

TEST_CASE("ExampleMultiplier handles edge cases", "[ExampleMultiplier]")
{
    ExampleMultiplier multiplier;

    SECTION("Multiplying large numbers")
    {
        multiplier.multiply(100000, 200000);
        REQUIRE(multiplier.result() == 20000000000);
    }

    SECTION("Multiplying by one")
    {
        multiplier.multiply(1, 9999);
        REQUIRE(multiplier.result() == 9999);
    }
}
