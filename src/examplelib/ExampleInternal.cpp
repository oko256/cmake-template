#include "ExampleInternal.h"
#include "x_NAME_x_version.h"
#include <spdlog/spdlog.h>

void examplelib::internal_func(const std::string& a)
{
    spdlog::info("Example of non-exported function: {} (lib ver {})", a, x_NAME_x_version_string());
}
