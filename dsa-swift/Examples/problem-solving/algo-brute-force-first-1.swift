// Generated from src/dsa/content/lessons/problem-solving/algo-brute-force-first.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func smallestMissing(_ numbers: [Int]) -> Int {
    var candidate = 1
    while numbers.contains(candidate) {
        candidate += 1
    }
    return candidate
}

print(smallestMissing([3, 1, 5]))
print(smallestMissing([1, 2, 3]))
print(smallestMissing([-4, 0, 7]))
print(smallestMissing([]))
