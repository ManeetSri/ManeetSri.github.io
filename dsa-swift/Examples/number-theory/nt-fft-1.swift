// Generated from src/dsa/content/lessons/number-theory/nt-fft.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Schoolbook polynomial multiplication: every coefficient of a meets every coefficient of b
func naiveMultiply(_ a: [Int], _ b: [Int]) -> [Int] {
    var c = Array(repeating: 0, count: a.count + b.count - 1)
    for i in a.indices {
        for j in b.indices {
            c[i + j] += a[i] * b[j]
        }
    }
    return c
}

print(naiveMultiply([1, 2, 3], [4, 5]))         // (1 + 2x + 3x²)(4 + 5x)
print(naiveMultiply([3, 2, 1], [5, 4]))         // 123 × 45, digits lowest first
print(123 * 45)
