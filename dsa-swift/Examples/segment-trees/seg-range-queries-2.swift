// Generated from src/dsa/content/lessons/segment-trees/seg-range-queries.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Sums of blocks: the whole array, its halves, their halves, and so on down to single items
let items = [5, 3, 7, 9, 6, 4, 1, 2]
var levels = [items]
while levels.last!.count > 1 {
    let below = levels.last!
    let above = stride(from: 0, to: below.count, by: 2).map { below[$0] + below[$0 + 1] }
    levels.append(above)
}
for level in levels.reversed() {
    print("blocks of \(items.count / level.count):", level)
}
