// Generated from src/dsa/content/lessons/recursion/rec-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sum(_ items: [Int], from index: Int = 0) -> Int {
    if index == items.count {
        return 0                            // nothing left
    }
    return items[index] + sum(items, from: index + 1)
}

print(sum([3, 1, 4, 1, 5]))
print(sum([]))
