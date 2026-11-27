// Generated from src/dsa/content/lessons/efficient-sorts/sort-swift-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isSorted(_ items: [Int]) -> Bool {
    zip(items, items.dropFirst()).allSatisfy { $0 <= $1 }    // every neighbouring pair in order
}

func isSorted<T>(_ items: [T], by areInIncreasingOrder: (T, T) -> Bool) -> Bool {
    !zip(items, items.dropFirst()).contains { areInIncreasingOrder($1, $0) }   // no step down
}

print(isSorted([1, 2, 2, 5]), isSorted([1, 3, 2]), isSorted([]))
print(isSorted(["kiwi", "fig", "banana"]) { $0.count < $1.count })
print(isSorted([9, 7, 7, 1], by: >))
