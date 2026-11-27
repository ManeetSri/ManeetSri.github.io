// Reference solution: Rain gauge blocks. Sqrt decomposition: blocks of ⌈√n⌉ gauges, each storing its
// total and its maximum. `set` fixes the total with the difference and rescans its block for the
// maximum (a lowered maximum can't be fixed any other way). A query takes whole blocks from their
// summaries and the loose gauges at its ends one by one. O(√n) per operation, O(n) space.

public enum RainGaugeBlocks {
    public final class Gauges {
        private var readings: [Int]
        private var blockTotal: [Int]
        private var blockMax: [Int]
        private let blockSize: Int

        public init(readings: [Int]) {
            self.readings = readings
            var size = 1
            while size * size < readings.count { size += 1 }
            blockSize = size
            let blockCount = (readings.count + size - 1) / size
            blockTotal = [Int](repeating: 0, count: blockCount)
            blockMax = [Int](repeating: Int.min, count: blockCount)
            for (i, reading) in readings.enumerated() {
                blockTotal[i / size] += reading
                blockMax[i / size] = max(blockMax[i / size], reading)
            }
        }

        public func set(_ index: Int, to reading: Int) {
            let block = index / blockSize
            blockTotal[block] += reading - readings[index]
            readings[index] = reading
            let start = block * blockSize
            let end = min(start + blockSize, readings.count)
            var largest = Int.min
            for i in start..<end {
                largest = max(largest, readings[i])
            }
            blockMax[block] = largest
        }

        public func total(_ left: Int, _ right: Int) -> Int {
            var sum = 0
            var i = left
            while i <= right {
                if i % blockSize == 0 && i + blockSize - 1 <= right {
                    sum += blockTotal[i / blockSize]          // a whole block
                    i += blockSize
                } else {
                    sum += readings[i]                        // a loose gauge
                    i += 1
                }
            }
            return sum
        }

        public func heaviest(_ left: Int, _ right: Int) -> Int {
            var best = Int.min
            var i = left
            while i <= right {
                if i % blockSize == 0 && i + blockSize - 1 <= right {
                    best = max(best, blockMax[i / blockSize])
                    i += blockSize
                } else {
                    best = max(best, readings[i])
                    i += 1
                }
            }
            return best
        }
    }
}
