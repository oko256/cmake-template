#include "ExampleMultiplier.h"
#include "examplelib/ExampleConcat.h"
#include "x_NAME_x_version.h"
#include <spdlog/spdlog.h>
#include <string>

int main()
{
    spdlog::info("{}", x_NAME_x_preamble());
    spdlog::info("{}", x_NAME_x_description());
    ExampleMultiplier x;
    x.multiply(3, 4);
    spdlog::info("{}", x.result());
    spdlog::info("Library call result: {}", examplelib::normal_concat("hello ", "world"));
    return 0;
}
