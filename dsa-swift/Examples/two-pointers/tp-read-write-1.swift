// Generated from src/dsa/content/lessons/two-pointers/tp-read-write.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func removeAll(_ value: Int, from items: inout [Int]) -> Int {
    var write = 0
    for read in items.indices {
        if items[read] != value {
            items[write] = items[read]
            write += 1
        }
    }
    return write
}

var items = [3, 1, 3, 2, 3, 4]
let kept = removeAll(3, from: &items)
print(kept, items)
items.removeLast(items.count - kept)
print(items)
