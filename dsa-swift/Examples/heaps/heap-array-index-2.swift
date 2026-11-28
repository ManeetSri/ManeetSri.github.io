// Generated from src/dsa/content/lessons/heaps/heap-array-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isMinHeap(_ items: [Int]) -> Bool {
    for child in items.indices.dropFirst() {
        if items[(child - 1) / 2] > items[child] {
            return false
        }
    }
    return true
}

print(isMinHeap([1, 3, 2, 7, 4, 5, 9]))
print(isMinHeap([1, 2, 3, 4, 5, 6, 7]))
print(isMinHeap([2, 1, 3]))
print(isMinHeap([1, 5, 2, 4]))
