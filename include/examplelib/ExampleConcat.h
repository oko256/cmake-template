#pragma once

#include <examplelib_export.h>
#include <string>

/// Example library functions.
namespace examplelib {
/// Concatenates two strings normally.
EXAMPLELIB_EXPORT std::string normal_concat(const std::string& a, const std::string& b);
/// Concatenates two strings twice.
EXAMPLELIB_EXPORT std::string double_concat(const std::string& a, const std::string& b);
}
