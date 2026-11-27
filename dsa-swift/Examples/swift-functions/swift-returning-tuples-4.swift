// Generated from src/dsa/content/lessons/swift-functions/swift-returning-tuples.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstAndLast(of numbers: [Int]) -> (first: Int, last: Int)? {
    guard let first = numbers.first, let last = numbers.last else {
        return nil
    }
    return (first, last)
}

if let ends = firstAndLast(of: [5, 9, 2]) {
    print("Starts with \(ends.first), ends with \(ends.last)")
}

if firstAndLast(of: []) == nil {
    print("No ends to report")
}
