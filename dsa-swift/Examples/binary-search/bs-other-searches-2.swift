// Generated from src/dsa/content/lessons/binary-search/bs-other-searches.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func jumpSearch(_ items: [Int], for target: Int) -> (index: Int?, comparisons: Int) {
    let n = items.count
    let step = max(1, Int(Double(n).squareRoot()))
    var comparisons = 0
    var blockStart = 0
    // Jump while the last value of the current block is still too small
    while blockStart < n {
        let blockEnd = min(blockStart + step, n) - 1
        comparisons += 1
        if items[blockEnd] >= target { break }
        blockStart += step
    }
    // Walk through that one block
    var i = blockStart
    while i < min(blockStart + step, n) {
        comparisons += 1
        if items[i] == target { return (i, comparisons) }
        if items[i] > target { break }
        i += 1
    }
    return (nil, comparisons)
}

let items = Array(0..<1_000_000)
print(jumpSearch(items, for: 123_456))
print(jumpSearch(items, for: 999_999))
