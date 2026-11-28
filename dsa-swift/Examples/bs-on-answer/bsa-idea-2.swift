// Generated from src/dsa/content/lessons/bs-on-answer/bsa-idea.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// The smallest x in the range for which feasible(x) is true,
/// or range.upperBound if there's none. feasible must be monotonic.
func firstTrue(in range: Range<Int>, where feasible: (Int) -> Bool) -> Int {
    var low = range.lowerBound
    var high = range.upperBound
    while low < high {
        let mid = low + (high - low) / 2
        if feasible(mid) {
            high = mid          // mid works: the answer is mid or something smaller
        } else {
            low = mid + 1       // mid fails, and so does everything below it
        }
    }
    return low
}

var checks = 0
let rows = firstTrue(in: 0..<1_001) { rows in
    checks += 1
    let cans = rows * (rows + 1) / 2
    print("try \(rows) rows: \(cans) cans")
    return cans >= 1_000
}
print("fewest rows: \(rows), after \(checks) checks")
