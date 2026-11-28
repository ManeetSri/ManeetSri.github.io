// Generated from src/dsa/content/lessons/linear-sorts/sort-bucket.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func insertionSort(_ items: inout [Double]) {
    guard items.count > 1 else { return }
    for i in 1..<items.count {
        let key = items[i]
        var gap = i
        while gap > 0 && items[gap - 1] > key {
            items[gap] = items[gap - 1]
            gap -= 1
        }
        items[gap] = key
    }
}

func bucketSort(_ values: [Double]) -> [Double] {
    let n = values.count
    guard n > 1 else { return values }
    var buckets = [[Double]](repeating: [], count: n)
    for value in values {
        buckets[Int(value * Double(n))].append(value)      // a value in [0, 1) lands in 0 to n - 1
    }
    for (index, bucket) in buckets.enumerated() where !bucket.isEmpty {
        print("bucket \(index):", bucket)
    }
    var result: [Double] = []
    for var bucket in buckets {
        insertionSort(&bucket)
        result += bucket
    }
    return result
}

print(bucketSort([0.42, 0.32, 0.23, 0.52, 0.25, 0.47, 0.51, 0.08]))
