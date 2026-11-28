// Generated from src/dsa/content/lessons/swift-control-flow/swift-guard.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isSorted(_ numbers: [Int]) -> Bool {
    guard numbers.count > 1 else {
        return true // zero or one element is always sorted
    }
    for i in 1..<numbers.count {
        guard numbers[i - 1] <= numbers[i] else {
            return false
        }
    }
    return true
}

print(isSorted([1, 3, 3, 8]))
print(isSorted([4, 2, 9]))
print(isSorted([]))
