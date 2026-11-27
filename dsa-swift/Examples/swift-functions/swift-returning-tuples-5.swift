// Generated from src/dsa/content/lessons/swift-functions/swift-returning-tuples.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func largestWithIndex(in numbers: [Int]) -> (index: Int, value: Int)? {
    guard !numbers.isEmpty else { return nil }
    var best = (index: 0, value: numbers[0])
    for index in 1..<numbers.count {
        if numbers[index] > best.value {
            best = (index: index, value: numbers[index])
        }
    }
    return best
}

if let best = largestWithIndex(in: [12, 40, 7, 40, 3]) {
    print("\(best.value) at index \(best.index)")
}
