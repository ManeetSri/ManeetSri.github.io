// Generated from src/dsa/content/lessons/prefix-sums/prefix-hashmap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestSubarray(_ numbers: [Int], summingTo k: Int) -> Int {
    var firstSeen: [Int: Int] = [0: 0]   // prefix value -> smallest i with prefix[i] equal to it
    var running = 0
    var best = 0
    for (index, value) in numbers.enumerated() {
        running += value
        let end = index + 1              // running is prefix[end]
        if let start = firstSeen[running - k] {
            best = max(best, end - start)
        }
        if firstSeen[running] == nil {
            firstSeen[running] = end
        }
    }
    return best
}

print(longestSubarray([1, -1, 5, -2, 3], summingTo: 3))
print(longestSubarray([2, 2, 2], summingTo: 5))
