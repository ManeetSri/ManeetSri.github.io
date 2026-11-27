// Generated from src/dsa/content/lessons/number-theory/nt-special-numbers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Catalan numbers by the recurrence: split at the bracket that closes the first "("
var catalan = [1]
for n in 1...15 {
    var total = 0
    for i in 0..<n {
        total += catalan[i] * catalan[n - 1 - i]
    }
    catalan.append(total)
}
print(Array(catalan[0...10]))

// Brute force: count balanced strings of n pairs by trying every string of 2n brackets
func balancedCount(_ n: Int) -> Int {
    var count = 0
    for mask in 0..<(1 << (2 * n)) {
        var depth = 0
        var ok = true
        for bit in 0..<(2 * n) {
            depth += mask & (1 << bit) != 0 ? 1 : -1
            if depth < 0 { ok = false; break }
        }
        if ok && depth == 0 { count += 1 }
    }
    return count
}
print((1...7).map(balancedCount))
