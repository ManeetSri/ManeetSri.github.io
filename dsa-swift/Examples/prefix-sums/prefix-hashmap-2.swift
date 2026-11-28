// Generated from src/dsa/content/lessons/prefix-sums/prefix-hashmap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countSubarrays(_ numbers: [Int], summingTo k: Int) -> Int {
    var seen: [Int: Int] = [0: 1]    // the empty prefix, before any number
    var running = 0
    var count = 0
    for value in numbers {
        running += value
        count += seen[running - k, default: 0]
        seen[running, default: 0] += 1
    }
    return count
}

print(countSubarrays([1, 2, -1, 3, -2, 2], summingTo: 3))
print(countSubarrays([1, -1, 1, -1], summingTo: 0))
print(countSubarrays([], summingTo: 0))
