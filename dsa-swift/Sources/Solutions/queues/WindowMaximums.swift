// Reference solution: Window maximums. A monotonic deque of indexes whose values decrease from front
// to back. For each index: expire the front if it has left the window, pop smaller-or-equal values
// from the back (they can never be a maximum again), push the index, and once the first window is
// complete, record the front's value. Each index is pushed once and popped at most once: O(n) time,
// O(k) space for the deque.

import DSAKit

public enum WindowMaximums {
    public static func maxima(in values: [Int], windowSize k: Int) -> [Int] {
        var result: [Int] = []
        result.reserveCapacity(Swift.max(0, values.count - k + 1))
        var window = Deque<Int>()                    // indexes, values decreasing front to back
        for i in values.indices {
            if let front = window.first, front <= i - k {
                window.popFirst()
            }
            while let back = window.last, values[back] <= values[i] {
                window.popLast()
            }
            window.append(i)
            if i >= k - 1 {
                result.append(values[window.first!])
            }
        }
        return result
    }
}
