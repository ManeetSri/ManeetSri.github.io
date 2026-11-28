// Generated from src/dsa/content/lessons/range-queries/rq-sparse-table.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The same table with + instead of min: the overlapping trick double-counts
let values = [7, 2, 9, 4, 8, 1, 6, 3]
var table = [values]
var j = 1
while (1 << j) <= values.count {
    let previous = table[j - 1]
    let half = 1 << (j - 1)
    table.append((0...(values.count - (1 << j))).map { previous[$0] + previous[$0 + half] })
    j += 1
}

func floorLog2(_ x: Int) -> Int {
    Int.bitWidth - 1 - x.leadingZeroBitCount     // the position of the highest set bit
}

/// Wrong: the two blocks overlap, so the middle is added twice
func overlappingSum(_ left: Int, _ right: Int) -> Int {
    let j = floorLog2(right - left + 1)
    return table[j][left] + table[j][right - (1 << j) + 1]
}

/// Right: split the length into powers of two (its binary digits) and add disjoint blocks
func disjointSum(_ left: Int, _ right: Int) -> Int {
    var total = 0
    var start = left
    var remaining = right - left + 1
    while remaining > 0 {
        let j = floorLog2(remaining)
        total += table[j][start]
        print("  block \(start)...\(start + (1 << j) - 1)")
        start += 1 << j
        remaining -= 1 << j
    }
    return total
}

print("true sum of 1...6:", values[1...6].reduce(0, +))
print("overlapping blocks:", overlappingSum(1, 6))
print("disjoint blocks:")
print("sum:", disjointSum(1, 6))
