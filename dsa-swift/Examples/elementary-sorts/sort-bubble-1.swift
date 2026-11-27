// Generated from src/dsa/content/lessons/elementary-sorts/sort-bubble.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var items = [5, 1, 4, 2, 8, 3]
for j in 0..<(items.count - 1) {
    let left = items[j]
    let right = items[j + 1]
    if left > right {
        items.swapAt(j, j + 1)
        print("\(left) > \(right): swap ->", items)
    } else {
        print("\(left) ≤ \(right): keep ->", items)
    }
}
