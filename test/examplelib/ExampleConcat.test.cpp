#include <catch2/catch_test_macros.hpp>
#include <examplelib/ExampleConcat.h>

TEST_CASE("normal_concat concatenates two strings", "[ExampleConcat]")
{
    REQUIRE(examplelib::normal_concat("foo", "bar") == std::string("foobar"));
}

TEST_CASE("double_concat concatenates two strings twice", "[ExampleConcat]")
{
    REQUIRE(examplelib::double_concat("foo", "bar") == std::string("foobarfoobar"));
}
