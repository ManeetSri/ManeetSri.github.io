// Generated from src/dsa/content/lessons/prefix-sums/prefix-hashmap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestBalanced(_ bits: [Int]) -> Int {
    var firstSeen: [Int: Int] = [0: 0]
    var running = 0
    var best = 0
    for (index, bit) in bits.enumerated() {
        running += bit == 1 ? 1 : -1
        if let start = firstSeen[running] {
            best = max(best, index + 1 - start)
        } else {
            firstSeen[running] = index + 1
        }
    }
    return best
}

print(longestBalanced([1, 1, 0, 1, 1, 0, 0, 1]))
print(longestBalanced([1, 1, 1]))
