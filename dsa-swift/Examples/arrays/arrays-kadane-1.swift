// Generated from src/dsa/content/lessons/arrays/arrays-kadane.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func bestSumBruteForce(_ numbers: [Int]) -> Int {
    var best = numbers[0]
    for start in numbers.indices {
        var sum = 0
        for end in start..<numbers.count {
            sum += numbers[end]
            best = max(best, sum)
        }
    }
    return best
}

print(bestSumBruteForce([-2, 1, -3, 4, -1, 2, 1, -5, 4]))
