// Generated from src/dsa/content/lessons/dp-strings/dps-lcs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var calls = 0

/// LCS length of the first i letters of a and the first j letters of b, by plain recursion
func lcs(_ a: [Character], _ b: [Character], _ i: Int, _ j: Int) -> Int {
    calls += 1
    if i == 0 || j == 0 {
        return 0                                        // an empty prefix shares nothing
    }
    if a[i - 1] == b[j - 1] {
        return lcs(a, b, i - 1, j - 1) + 1              // the last letters match: keep the pair
    }
    return max(lcs(a, b, i - 1, j), lcs(a, b, i, j - 1))   // drop the last letter of one or the other
}

for (first, second) in [("ABCBDAB", "BDCABA"), ("SWIFTLY", "SHIFTILY"), ("ABCDEFGHIJ", "KLMNOPQRST")] {
    calls = 0
    let length = lcs(Array(first), Array(second), first.count, second.count)
    print("\(first) and \(second): length \(length), \(calls) calls")
}
