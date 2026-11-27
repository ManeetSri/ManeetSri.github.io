// Generated from src/dsa/content/lessons/divide-conquer/dc-master-theorem.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

// T(n) = a · T(n / 2) + f(n), with T(1) = 1, evaluated exactly for n a power of two
func evaluate(_ a: Double, _ f: (Double) -> Double, _ n: Int) -> Double {
    n <= 1 ? 1 : a * evaluate(a, f, n / 2) + f(Double(n))
}

let recurrences: [(name: String, shape: String, a: Double, f: (Double) -> Double, theorem: String)] = [
    ("fast power", "T(n/2) + 1", 1, { _ in 1 }, "Θ(log n)"),
    ("quickselect, ideal", "T(n/2) + n", 1, { $0 }, "Θ(n)"),
    ("four-number summary", "2T(n/2) + 1", 2, { _ in 1 }, "Θ(n)"),
    ("merge sort", "2T(n/2) + n", 2, { $0 }, "Θ(n log n)"),
    ("Karatsuba", "3T(n/2) + n", 3, { $0 }, "Θ(n^1.585)"),
    ("quadratic combine", "2T(n/2) + n²", 2, { $0 * $0 }, "Θ(n²)"),
    ("Strassen", "7T(n/2) + n²", 7, { $0 * $0 }, "Θ(n^2.807)"),
]

let n = 1 << 20
for r in recurrences {
    let ratio = evaluate(r.a, r.f, 2 * n) / evaluate(r.a, r.f, n)
    let name = r.name.padding(toLength: 21, withPad: " ", startingAt: 0)
    let shape = r.shape.padding(toLength: 14, withPad: " ", startingAt: 0)
    print("\(name)\(shape)\(String(format: "%.3f", ratio))   \(r.theorem)")
}
