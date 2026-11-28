// Generated from src/dsa/content/lessons/problem-solving/algo-dry-runs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countRises(_ numbers: [Int]) -> Int {
    guard numbers.count > 1 else { return 0 }
    var rises = 0
    for i in 1..<numbers.count {
        if numbers[i] > numbers[i - 1] {
            rises += 1
        }
    }
    return rises
}

print(countRises([3, 5, 4, 8, 9]))
print(countRises([7]))
