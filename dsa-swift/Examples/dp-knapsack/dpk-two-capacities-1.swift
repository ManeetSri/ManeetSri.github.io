// Generated from src/dsa/content/lessons/dp-knapsack/dpk-two-capacities.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// The most strings you can choose using at most `zeros` 0s and `ones` 1s in total, each string at most once
func mostStrings(_ strings: [String], zeros: Int, ones: Int) -> Int {
    // best[z][o]: the most strings so far that fit in z zeros and o ones
    var best = Array(repeating: Array(repeating: 0, count: ones + 1), count: zeros + 1)
    for string in strings {
        let a = string.filter { $0 == "0" }.count        // this string's cost in zeros
        let b = string.count - a                         // and in ones
        if a > zeros || b > ones { continue }            // can never fit
        for z in stride(from: zeros, through: a, by: -1) {     // both capacities downward
            for o in stride(from: ones, through: b, by: -1) {
                best[z][o] = max(best[z][o], best[z - a][o - b] + 1)
            }
        }
    }
    return best[zeros][ones]
}

let strings = ["01", "1100", "0", "111", "00"]
print(mostStrings(strings, zeros: 3, ones: 3))   // "0", "111", "00"
print(mostStrings(strings, zeros: 1, ones: 1))   // "01" alone, or "0" alone
print(mostStrings(["11", "11", "0"], zeros: 0, ones: 3))
