// Reference solution: The longest steady stretch. A variable sliding window: extend the right end, and
// shrink the left end while the window's highest and lowest readings differ by more than the tolerance.
// Two monotonic deques of indexes (arrays with head indexes) track the window's maximum and minimum.
// Each index enters and leaves each deque once: O(n) time, O(n) space.

public enum LongestSteadyStretch {
    public static func longest(_ readings: [Int], tolerance: Int) -> Int {
        var highs: [Int] = []                     // indexes with decreasing readings, from highHead on
        var highHead = 0
        var lows: [Int] = []                      // indexes with increasing readings, from lowHead on
        var lowHead = 0
        var left = 0
        var best = 0
        for right in readings.indices {
            while highs.count > highHead && readings[highs[highs.count - 1]] <= readings[right] {
                highs.removeLast()
            }
            highs.append(right)
            while lows.count > lowHead && readings[lows[lows.count - 1]] >= readings[right] {
                lows.removeLast()
            }
            lows.append(right)
            while readings[highs[highHead]] - readings[lows[lowHead]] > tolerance {
                left += 1
                if highs[highHead] < left { highHead += 1 }
                if lows[lowHead] < left { lowHead += 1 }
            }
            best = max(best, right - left + 1)
        }
        return best
    }
}
