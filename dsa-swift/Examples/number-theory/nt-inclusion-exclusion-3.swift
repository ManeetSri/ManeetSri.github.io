// Generated from src/dsa/content/lessons/number-theory/nt-inclusion-exclusion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Derangements: no item stays in its own place. D(n) = (n - 1)·(D(n - 1) + D(n - 2))
var derangements = [1, 0]
for n in 2...12 {
    derangements.append((n - 1) * (derangements[n - 1] + derangements[n - 2]))
}
print(derangements)

// Inclusion–exclusion: D(n) = Σ (-1)^j · C(n, j) · (n - j)!
func factorial(_ n: Int) -> Int { n < 2 ? 1 : n * factorial(n - 1) }
func choose(_ n: Int, _ k: Int) -> Int { factorial(n) / (factorial(k) * factorial(n - k)) }
let formula = (0...10).map { n in
    (0...n).reduce(0) { total, j in total + (j % 2 == 0 ? 1 : -1) * choose(n, j) * factorial(n - j) }
}
print(formula)

// Brute force: count permutations of 0..<n with no fixed point
func countDerangements(_ n: Int) -> Int {
    var used = Array(repeating: false, count: n)
    func place(_ position: Int) -> Int {
        if position == n { return 1 }
        var count = 0
        for value in 0..<n where !used[value] && value != position {
            used[value] = true
            count += place(position + 1)
            used[value] = false
        }
        return count
    }
    return place(0)
}
print((0...8).map(countDerangements))
print(Double(derangements[12]) / Double(factorial(12)))
