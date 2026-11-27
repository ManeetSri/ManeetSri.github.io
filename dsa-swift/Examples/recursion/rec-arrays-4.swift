// Generated from src/dsa/content/lessons/recursion/rec-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func largest(_ items: [Int], from index: Int = 0) -> Int {
    if index == items.count - 1 {
        return items[index]                 // one element: it's the largest
    }
    return max(items[index], largest(items, from: index + 1))
}

func firstIndex(of target: Int, in items: [Int], from index: Int = 0) -> Int? {
    if index == items.count {
        return nil                          // ran off the end: not found
    }
    if items[index] == target {
        return index                        // found: stop early
    }
    return firstIndex(of: target, in: items, from: index + 1)
}

func isSorted(_ items: [Int], from index: Int = 0) -> Bool {
    if index >= items.count - 1 {
        return true                         // zero or one element left
    }
    return items[index] <= items[index + 1] && isSorted(items, from: index + 1)
}

let data = [4, 8, 15, 16, 23, 42]
print(largest(data))
print(firstIndex(of: 16, in: data) ?? -1, firstIndex(of: 7, in: data) ?? -1)
print(isSorted(data), isSorted([3, 1, 2]))
