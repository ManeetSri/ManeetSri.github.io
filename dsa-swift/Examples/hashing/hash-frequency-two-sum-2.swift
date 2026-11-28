// Generated from src/dsa/content/lessons/hashing/hash-frequency-two-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countPairs(_ numbers: [Int], summingTo target: Int) -> Int {
    var seen: [Int: Int] = [:]          // value -> how many times it has appeared so far
    var pairs = 0
    for number in numbers {
        pairs += seen[target - number, default: 0]
        seen[number, default: 0] += 1
    }
    return pairs
}

print(countPairs([1, 5, 3, 3, 3], summingTo: 6))
print(countPairs([2, 2, 2, 2], summingTo: 4))
print(countPairs([1, 2, 3], summingTo: 10))
