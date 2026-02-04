#pragma once

#include <cstdint>

/// A simple class that multiplies two integers and stores the result.
class ExampleMultiplier {
public:
    ExampleMultiplier() = default;

    /// Multiplies two integers and stores the result.
    void                  multiply(int64_t a, int64_t b);
    /// Returns the stored product.
    [[nodiscard]] int64_t result() const;

private:
    int64_t product{};
};
