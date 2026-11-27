// Generated from src/dsa/content/lessons/divide-conquer/dc-karatsuba.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Karatsuba on numbers small enough for Int, printing the pieces of the top-level split
func powerOfTen(_ exponent: Int) -> Int {
    var result = 1
    for _ in 0..<exponent {
        result *= 10
    }
    return result
}

func karatsuba(_ x: Int, _ y: Int, show: Bool = false) -> Int {
    if x < 10 || y < 10 {
        return x * y                                    // a single digit: multiply directly
    }
    let m = max(String(x).count, String(y).count) / 2
    let base = powerOfTen(m)
    let (x1, x0) = x.quotientAndRemainder(dividingBy: base)
    let (y1, y0) = y.quotientAndRemainder(dividingBy: base)
    let high = karatsuba(x1, y1)                         // x1 · y1
    let low = karatsuba(x0, y0)                          // x0 · y0
    let middle = karatsuba(x1 + x0, y1 + y0) - high - low    // x1 · y0 + x0 · y1, with one product
    if show {
        print("x1 = \(x1), x0 = \(x0), y1 = \(y1), y0 = \(y0)")
        print("high = \(high), low = \(low), middle = (\(x1 + x0) × \(y1 + y0)) - \(high) - \(low) = \(middle)")
    }
    return high * base * base + middle * base + low
}

let product = karatsuba(1234, 5678, show: true)
print(product, product == 1234 * 5678)
