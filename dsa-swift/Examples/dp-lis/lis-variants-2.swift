// Generated from src/dsa/content/lessons/dp-lis/lis-variants.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func largestDivisibleSubset(_ numbers: [Int]) -> [Int] {
    let sorted = numbers.sorted()
    guard !sorted.isEmpty else { return [] }
    var size = Array(repeating: 1, count: sorted.count)     // the biggest chain ending at i
    var parent = Array(repeating: -1, count: sorted.count)
    var end = 0
    for i in sorted.indices {
        for j in 0..<i where sorted[i] % sorted[j] == 0 && size[j] + 1 > size[i] {
            size[i] = size[j] + 1
            parent[i] = j
        }
        if size[i] > size[end] {
            end = i
        }
    }
    var subset: [Int] = []
    var index = end
    while index != -1 {
        subset.append(sorted[index])
        index = parent[index]
    }
    return subset.reversed()
}

print(largestDivisibleSubset([9, 4, 18, 2, 3, 36, 8]))
print(largestDivisibleSubset([5, 7, 11]))
