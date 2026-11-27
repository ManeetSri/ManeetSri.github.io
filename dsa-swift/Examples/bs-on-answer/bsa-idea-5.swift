// Generated from src/dsa/content/lessons/bs-on-answer/bsa-idea.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstTrue(in range: Range<Int>, where feasible: (Int) -> Bool) -> Int {
    var low = range.lowerBound
    var high = range.upperBound
    while low < high {
        let mid = low + (high - low) / 2
        if feasible(mid) { high = mid } else { low = mid + 1 }
    }
    return low
}

let target = 1_000_000_000_000

// Try 0, 1, 2, … rows in turn
var linearChecks = 1
var rows = 0
while rows * (rows + 1) / 2 < target {
    rows += 1
    linearChecks += 1
}
print("one by one: \(rows) rows after \(linearChecks) checks")

// 2,000,000 rows hold about 2 × 10¹² cans, so the answer is below that
var binaryChecks = 0
let found = firstTrue(in: 0..<2_000_000) { rows in
    binaryChecks += 1
    return rows * (rows + 1) / 2 >= target
}
print("binary search: \(found) rows after \(binaryChecks) checks")
