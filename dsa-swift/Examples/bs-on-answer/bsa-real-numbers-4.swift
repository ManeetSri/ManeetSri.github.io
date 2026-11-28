// Generated from src/dsa/content/lessons/bs-on-answer/bsa-real-numbers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

func power(_ base: Double, _ n: Int) -> Double {
    var result = 1.0
    for _ in 0..<n {
        result *= base
    }
    return result
}

func nthRoot(_ x: Double, _ n: Int) -> Double {
    var low = 0.0
    var high = max(1.0, x)               // roots of numbers below 1 are bigger than the number
    for _ in 0..<100 {
        let mid = (low + high) / 2
        if power(mid, n) >= x {
            high = mid
        } else {
            low = mid
        }
    }
    return high
}

print(nthRoot(1e18, 6))
print(String(format: "%.6f", nthRoot(2, 3)))
print(String(format: "%.6f", nthRoot(0.25, 2)))
print(String(format: "%.6f", nthRoot(1e18, 6)))
print(String(format: "%.6f", nthRoot(10, 5)))
