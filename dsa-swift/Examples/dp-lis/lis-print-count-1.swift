// Generated from src/dsa/content/lessons/dp-lis/lis-print-count.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func oneLongestIncreasing(_ items: [Int]) -> [Int] {
    guard !items.isEmpty else { return [] }
    var length = Array(repeating: 1, count: items.count)
    var parent = Array(repeating: -1, count: items.count)   // the index before i in its best run
    for i in items.indices {
        for j in 0..<i where items[j] < items[i] && length[j] + 1 > length[i] {
            length[i] = length[j] + 1
            parent[i] = j
        }
    }
    var end = 0
    for i in items.indices where length[i] > length[end] {
        end = i                                              // the first index with the best length
    }
    var run: [Int] = []
    var index = end
    while index != -1 {
        run.append(items[index])
        index = parent[index]
    }
    return run.reversed()
}

print(oneLongestIncreasing([10, 9, 2, 5, 3, 7, 101, 18]))
print(oneLongestIncreasing([3, 4, 5, 1, 2]))
print(oneLongestIncreasing([5, 4, 3]))
