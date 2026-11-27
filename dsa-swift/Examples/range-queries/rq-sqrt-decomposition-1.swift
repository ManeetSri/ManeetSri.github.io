// Generated from src/dsa/content/lessons/range-queries/rq-sqrt-decomposition.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Sqrt decomposition for range sums with point updates
struct BlockSums {
    private var values: [Int]
    private var blockSums: [Int]
    private let blockSize: Int

    init(_ values: [Int]) {
        self.values = values
        var size = 1
        while size * size < values.count { size += 1 }      // ⌈√n⌉, at least 1
        blockSize = size
        blockSums = [Int](repeating: 0, count: (values.count + size - 1) / size)
        for (i, value) in values.enumerated() {
            blockSums[i / size] += value
        }
    }

    /// Sets values[index] to newValue: O(1)
    mutating func update(_ index: Int, to newValue: Int) {
        blockSums[index / blockSize] += newValue - values[index]
        values[index] = newValue
    }

    /// The sum of values[left...right]: O(√n)
    func sum(_ left: Int, _ right: Int) -> Int {
        var total = 0
        var i = left
        while i <= right {
            if i % blockSize == 0 && i + blockSize - 1 <= right {
                total += blockSums[i / blockSize]      // a whole block in one step
                i += blockSize
            } else {
                total += values[i]                     // a partial block, one element at a time
                i += 1
            }
        }
        return total
    }

    var blocks: [Int] { blockSums }
}

var visitors = BlockSums([4, 8, 1, 7, 3, 9, 2, 6, 5, 0])
print("block size 4, block sums:", visitors.blocks)
print("sum of 1...8:", visitors.sum(1, 8))
visitors.update(5, to: 20)
print("after visitors[5] = 20:", visitors.blocks)
print("sum of 1...8:", visitors.sum(1, 8))
print("sum of 4...7:", visitors.sum(4, 7))
