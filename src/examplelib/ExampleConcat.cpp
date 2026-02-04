#include "ExampleInternal.h"
#include <examplelib/ExampleConcat.h>

std::string examplelib::normal_concat(const std::string& a, const std::string& b)
{
    examplelib::internal_func(a);
    examplelib::internal_func(b);
    return a + b;
}

std::string examplelib::double_concat(const std::string& a, const std::string& b)
{
    examplelib::internal_func(a);
    examplelib::internal_func(b);
    return a + b + a + b;
}
