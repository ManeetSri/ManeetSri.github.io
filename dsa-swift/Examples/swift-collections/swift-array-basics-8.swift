// Generated from src/dsa/content/lessons/swift-collections/swift-array-basics.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func safeElement(_ numbers: [Int], at index: Int) -> Int? {
    guard numbers.indices.contains(index) else { return nil }
    return numbers[index]
}

let numbers = [10, 20, 30]
print(safeElement(numbers, at: 1) ?? -1)
print(safeElement(numbers, at: 3) ?? -1)
print(safeElement(numbers, at: -1) ?? -1)
