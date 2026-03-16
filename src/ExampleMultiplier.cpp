#include "ExampleMultiplier.h"
#include <stdexcept>

void ExampleMultiplier::multiply(int64_t a, int64_t b)
{
    m_product = a * b;

    // DEMO: This is just for testing branch coverage:
    const int64_t threshold = 20000000000;
    if (m_product > threshold) {
        throw std::runtime_error("Product is HUGE, wow!");
    }
}

int64_t ExampleMultiplier::result() const { return m_product; }
