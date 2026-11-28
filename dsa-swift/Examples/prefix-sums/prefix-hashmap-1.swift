// Generated from src/dsa/content/lessons/prefix-sums/prefix-hashmap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countSlowly(_ numbers: [Int], summingTo k: Int) -> Int {
    var count = 0
    for start in numbers.indices {
        var sum = 0
        for end in start..<numbers.count {
            sum += numbers[end]
            if sum == k {
                count += 1
            }
        }
    }
    return count
}

print(countSlowly([1, 2, -1, 3, -2, 2], summingTo: 3))
print(countSlowly([1, -1, 1, -1], summingTo: 0))
