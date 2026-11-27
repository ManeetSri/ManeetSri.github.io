// Generated from src/dsa/content/lessons/problem-solving/algo-brute-force-first.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func smallestMissingFast(_ numbers: [Int]) -> Int {
    let present = Set(numbers)
    var candidate = 1
    while present.contains(candidate) {
        candidate += 1
    }
    return candidate
}

print(smallestMissingFast([3, 1, 5]))
print(smallestMissingFast([1, 2, 3]))
