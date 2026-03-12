#include "ExampleMultiplier.h"

void ExampleMultiplier::multiply(int64_t a, int64_t b) { product_ = a * b; }

int64_t ExampleMultiplier::result() const { return product_; }
