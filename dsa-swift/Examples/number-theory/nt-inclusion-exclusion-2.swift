// Generated from src/dsa/content/lessons/number-theory/nt-inclusion-exclusion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Count 1…n divisible by any of the primes, depth first, skipping every product that passes n
func divisibleByAny(_ n: Int, _ primes: [Int]) -> Int {
    var total = 0
    func explore(_ start: Int, _ product: Int, _ size: Int) {
        for i in start..<primes.count {
            let next = product.multipliedReportingOverflow(by: primes[i])
            if next.overflow || next.partialValue > n { continue }   // n / product would be 0
            total += (size % 2 == 0 ? 1 : -1) * (n / next.partialValue)
            explore(i + 1, next.partialValue, size + 1)
        }
    }
    explore(0, 1, 0)
    return total
}

let firstPrimes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71]
print(divisibleByAny(100, [2, 3, 5]))
print(divisibleByAny(1_000_000_000_000_000_000, firstPrimes))
print(divisibleByAny(1_000, firstPrimes), (1...1000).filter { k in firstPrimes.contains { k % $0 == 0 } }.count)
