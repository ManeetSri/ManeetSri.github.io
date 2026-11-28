// Generated from src/dsa/content/lessons/arrays/arrays-merge-sorted.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func merge(_ first: [Int], _ second: [Int]) -> [Int] {
    var result: [Int] = []
    result.reserveCapacity(first.count + second.count)
    var i = 0
    var j = 0
    while i < first.count && j < second.count {
        if first[i] <= second[j] {
            result.append(first[i])
            i += 1
        } else {
            result.append(second[j])
            j += 1
        }
    }
    result.append(contentsOf: first[i...])       // at most one of these
    result.append(contentsOf: second[j...])      // still has elements
    return result
}

print(merge([1, 4, 7], [2, 3, 9]))
print(merge([5, 6], [1, 2, 3]))
print(merge([], [4, 8]))
