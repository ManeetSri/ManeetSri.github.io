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

/// The largest x in the range for which works(x) is true,
/// or range.lowerBound - 1 if there's none. works must be true … true, false … false.
func lastTrue(in range: Range<Int>, where works: (Int) -> Bool) -> Int {
    firstTrue(in: range) { !works($0) } - 1
}

let cans = 1_000
print("most rows:", lastTrue(in: 0..<(cans + 1)) { rows in rows * (rows + 1) / 2 <= cans })
print("fewest rows:", firstTrue(in: 0..<(cans + 1)) { rows in rows * (rows + 1) / 2 >= cans })
