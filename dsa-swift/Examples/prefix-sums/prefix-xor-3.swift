// Generated from src/dsa/content/lessons/prefix-sums/prefix-xor.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countSubarrays(_ numbers: [Int], withXor k: Int) -> Int {
    var seen: [Int: Int] = [0: 1]
    var running = 0
    var count = 0
    for value in numbers {
        running ^= value
        count += seen[running ^ k, default: 0]
        seen[running, default: 0] += 1
    }
    return count
}

print(countSubarrays([5, 3, 6, 2, 7, 1], withXor: 7))
print(countSubarrays([5, 3, 6, 2, 7, 1], withXor: 0))
print(countSubarrays([1, 2, 3, 1, 2, 3], withXor: 0))
