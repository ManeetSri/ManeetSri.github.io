// Generated from src/dsa/content/lessons/binary-search/bs-partitioning-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

extension RandomAccessCollection {
    func partitionPoint(where belongsInSecondPartition: (Element) -> Bool) -> Index {
        var low = startIndex
        var remaining = count
        while remaining > 0 {
            let half = remaining / 2
            let middle = index(low, offsetBy: half)
            if belongsInSecondPartition(self[middle]) {
                remaining = half
            } else {
                low = index(after: middle)
                remaining -= half + 1
            }
        }
        return low
    }
}

let numbers = [1, 2, 3, 4, 5, 6, 7]
print(numbers.partitionPoint { $0 == 2 })        // not partitioned: no, yes, no, no, …
print(numbers.partitionPoint { $0 >= 2 })        // partitioned: no, yes, yes, …
