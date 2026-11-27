// Generated from src/dsa/content/lessons/dp-strings/dps-lcs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// LCS length with two rows: each row only needs the one above it
func lcsLength(_ first: String, _ second: String) -> Int {
    let a = Array(first), b = Array(second)
    var previous = Array(repeating: 0, count: b.count + 1)
    var current = previous
    for i in 0..<a.count {                      // filling row i + 1 of the table
        for j in 0...b.count {
            if j == 0 {
                current[j] = 0
            } else if a[i] == b[j - 1] {
                current[j] = previous[j - 1] + 1
            } else {
                current[j] = max(previous[j], current[j - 1])
            }
        }
        swap(&previous, &current)
    }
    return previous[b.count]
}

print(lcsLength("ABCBDAB", "BDCABA"), lcsLength("", "abc"), lcsLength("SWIFTLY", "SHIFTILY"))
