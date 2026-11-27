// Generated from src/dsa/content/lessons/number-theory/nt-special-numbers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The closed form C(2n, n) / (n + 1), with exact Ints for small n
func choose(_ n: Int, _ k: Int) -> Int {
    var result = 1
    for i in 0..<k { result = result * (n - i) / (i + 1) }
    return result
}
print((0...10).map { choose(2 * $0, $0) / ($0 + 1) })
print((0...10).map { choose(2 * $0, $0) - choose(2 * $0, $0 + 1) })

// Catalan numbers grow like 4ⁿ: the 36th no longer fits in an Int
var catalan = [1]
for n in 1...40 {
    var total = 0
    var overflow = false
    for i in 0..<n {
        let product = catalan[i].multipliedReportingOverflow(by: catalan[n - 1 - i])
        let sum = total.addingReportingOverflow(product.partialValue)
        if product.overflow || sum.overflow { overflow = true; break }
        total = sum.partialValue
    }
    if overflow {
        print("C(\(n)) overflows an Int")
        break
    }
    catalan.append(total)
}
print("C(\(catalan.count - 1)) =", catalan.last!)
