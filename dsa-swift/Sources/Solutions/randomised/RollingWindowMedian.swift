// Reference solution: Rolling window median. Two heaps of (value, index) pairs, the lower half in a
// max-heap and the upper half in a min-heap, with lazy deletion: an entry is stale once its index has
// left the window, and stale entries are popped only when they reach a top. Live sizes are tracked
// separately, the leaving pair is assigned to a half by comparing it with the lower top (pairs are
// distinct, and everything in lower is ≤ everything in upper), and rebalancing uses the live sizes.
// O(n log n) time, O(n) space in the worst case for stale entries.

import DSAKit

public enum RollingWindowMedian {
    public static func medians(_ readings: [Int], window k: Int) -> [Double] {
        typealias Entry = (value: Int, index: Int)
        var lower = Heap<Entry>(areInIncreasingOrder: { $0 > $1 })   // the smaller half, largest on top
        var upper = Heap<Entry>(areInIncreasingOrder: { $0 < $1 })   // the larger half, smallest on top
        var lowerSize = 0                        // live entries in each half
        var upperSize = 0
        var windowStart = 0                      // entries with a smaller index are stale

        func clean(_ heap: inout Heap<Entry>) {
            while let top = heap.peek(), top.index < windowStart {
                heap.pop()
            }
        }

        var result: [Double] = []
        result.reserveCapacity(readings.count - k + 1)
        for (i, reading) in readings.enumerated() {
            let entry = (reading, i)
            if let top = lower.peek(), entry > top {
                upper.insert(entry)
                upperSize += 1
            } else {
                lower.insert(entry)
                lowerSize += 1
            }
            if i >= k {                          // readings[i - k] leaves the window
                let leaving = (readings[i - k], i - k)
                if let top = lower.peek(), leaving <= top { lowerSize -= 1 } else { upperSize -= 1 }
                windowStart = i - k + 1
            }
            if lowerSize > upperSize + 1 {       // rebalance by live sizes
                clean(&lower)
                upper.insert(lower.pop()!)
                lowerSize -= 1
                upperSize += 1
            } else if upperSize > lowerSize {
                clean(&upper)
                lower.insert(upper.pop()!)
                upperSize -= 1
                lowerSize += 1
            }
            clean(&lower)
            clean(&upper)
            if i >= k - 1 {
                let middle = lower.peek()!.value
                result.append(k % 2 == 1 ? Double(middle) : (Double(middle) + Double(upper.peek()!.value)) / 2)
            }
        }
        return result
    }
}
