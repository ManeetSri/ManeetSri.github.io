// Generated from src/dsa/content/lessons/prefix-sums/prefix-pivot-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func equalSplit(_ numbers: [Int]) -> Int? {
    let total = numbers.reduce(0, +)
    guard total % 2 == 0 else { return nil }
    var leftSum = 0
    for i in 0..<max(numbers.count - 1, 0) {   // the right part must keep at least one element
        leftSum += numbers[i]
        if leftSum == total / 2 {
            return i + 1                       // the right part starts here
        }
    }
    return nil
}

print(equalSplit([3, 1, 2, 2]) as Any)
print(equalSplit([1, 2, 4]) as Any)
print(equalSplit([4, -4]) as Any)
