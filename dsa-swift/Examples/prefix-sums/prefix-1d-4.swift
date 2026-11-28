// Generated from src/dsa/content/lessons/prefix-sums/prefix-1d.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct RangeSums {
    private let prefix: [Int]

    init(_ values: [Int]) {
        var prefix = [0]
        prefix.reserveCapacity(values.count + 1)
        for value in values {
            prefix.append(prefix.last! + value)
        }
        self.prefix = prefix
    }

    // The total of values[range], for a half-open range like 2..<5
    func sum(_ range: Range<Int>) -> Int {
        prefix[range.upperBound] - prefix[range.lowerBound]
    }
}

let steps = RangeSums([1200, 800, 3400, 0, 2600, 5100, 900])
print(steps.sum(0..<7))
print(steps.sum(2..<5))
print(steps.sum(3..<3))
