#include "ExampleMultiplier.h"

void ExampleMultiplier::multiply(int64_t a, int64_t b) { m_product = a * b; }

int64_t ExampleMultiplier::result() const { return m_product; }
