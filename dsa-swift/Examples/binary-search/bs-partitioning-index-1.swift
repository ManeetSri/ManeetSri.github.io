// Generated from src/dsa/content/lessons/binary-search/bs-partitioning-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

extension RandomAccessCollection {
    /// The index of the first element that satisfies the predicate, or endIndex if none does.
    /// The collection must be partitioned: every false before every true. O(log n).
    func partitionPoint(where belongsInSecondPartition: (Element) -> Bool) -> Index {
        var low = startIndex
        var remaining = count                    // the candidates are [low, low + remaining)
        while remaining > 0 {
            let half = remaining / 2
            let middle = index(low, offsetBy: half)
            if belongsInSecondPartition(self[middle]) {
                remaining = half                 // middle could be the first true: keep it
            } else {
                low = index(after: middle)       // middle and everything before it are false
                remaining -= half + 1
            }
        }
        return low
    }
}

let scores = [12, 31, 48, 50, 50, 77, 91]
print(scores.partitionPoint { $0 >= 50 }, scores.partitionPoint { $0 > 50 }, scores.partitionPoint { $0 > 100 })

let tail = scores[2...]                          // a slice: its indexes are 2 to 6
print(tail.startIndex, tail.partitionPoint { $0 >= 50 })

let firstBigSquare = (0..<1_000_000).partitionPoint { $0 * $0 >= 500_000_000 }
print(firstBigSquare)

let names = ["Ana", "Ben", "Cleo", "Dev", "Eli"]
print(names.partitionPoint { $0 >= "C" })
