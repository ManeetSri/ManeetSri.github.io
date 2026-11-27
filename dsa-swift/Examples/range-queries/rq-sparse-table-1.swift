// Generated from src/dsa/content/lessons/range-queries/rq-sparse-table.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Build the levels of a sparse table for range minimums and print them
let prices = [7, 2, 9, 4, 8, 1, 6, 3]
var table = [prices]                       // level 0: blocks of length 1
var length = 2
while length <= prices.count {
    let previous = table[table.count - 1]
    let half = length / 2
    var level: [Int] = []
    for start in 0...(prices.count - length) {
        level.append(min(previous[start], previous[start + half]))
    }
    table.append(level)
    length *= 2
}
for (j, level) in table.enumerated() {
    print("level \(j), blocks of \(1 << j):", level)
}
