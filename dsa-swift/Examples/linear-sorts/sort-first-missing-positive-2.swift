// Generated from src/dsa/content/lessons/linear-sorts/sort-first-missing-positive.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstMissingPositiveByMarking(_ numbers: inout [Int]) -> Int {
    let n = numbers.count
    // 1. Values that can't matter become n + 1, so every value is positive
    for i in 0..<n where numbers[i] < 1 || numbers[i] > n {
        numbers[i] = n + 1
    }
    // 2. Each value v from 1 to n marks index v - 1 by making it negative
    for i in 0..<n {
        let value = abs(numbers[i])
        if value <= n && numbers[value - 1] > 0 {
            numbers[value - 1] = -numbers[value - 1]
        }
    }
    // 3. The first index that's still positive was never marked
    for i in 0..<n where numbers[i] > 0 {
        return i + 1
    }
    return n + 1
}

var a = [7, 3, -2, 1, 9, 2]
print(firstMissingPositiveByMarking(&a), a)
