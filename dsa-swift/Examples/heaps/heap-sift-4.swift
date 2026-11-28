// Generated from src/dsa/content/lessons/heaps/heap-sift.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct BinaryHeap {
    var items: [Int] = []
    let areInIncreasingOrder: (Int, Int) -> Bool     // true when the first should be nearer the top

    mutating func push(_ value: Int) {
        items.append(value)
        var child = items.count - 1
        while child > 0 {
            let parent = (child - 1) / 2
            if !areInIncreasingOrder(items[child], items[parent]) { break }
            items.swapAt(child, parent)
            child = parent
        }
    }

    mutating func pop() -> Int? {
        guard !items.isEmpty else { return nil }
        items.swapAt(0, items.count - 1)
        let top = items.removeLast()
        var parent = 0
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var first = parent
            if left < items.count && areInIncreasingOrder(items[left], items[first]) { first = left }
            if right < items.count && areInIncreasingOrder(items[right], items[first]) { first = right }
            if first == parent { break }
            items.swapAt(parent, first)
            parent = first
        }
        return top
    }
}

var smallestFirst = BinaryHeap(areInIncreasingOrder: <)
var largestFirst = BinaryHeap(areInIncreasingOrder: >)
for value in [5, 3, 8, 1, 9, 2] {
    smallestFirst.push(value)
    largestFirst.push(value)
}
print(smallestFirst.items, largestFirst.items)

var ascending: [Int] = []
while let value = smallestFirst.pop() { ascending.append(value) }
var descending: [Int] = []
while let value = largestFirst.pop() { descending.append(value) }
print(ascending, descending)
