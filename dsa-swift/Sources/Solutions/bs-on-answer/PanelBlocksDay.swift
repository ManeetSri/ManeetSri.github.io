// Reference solution: Earliest day for panel blocks. First rule out the impossible case, blocks ×
// blockSize > panels, without multiplying (the product can overflow): for positive whole numbers that's
// the same as blocks > panels / blockSize. Then binary search on the day. On day d, scan once, counting
// the current run of online panels; every time the run reaches blockSize, that's a block and the run
// starts again. Later days only switch more panels on, so the count never drops. The answer lies between
// the earliest and latest switch-on days. O(n log(max day)) time, O(1) space.

public enum PanelBlocksDay {
    public static func earliestDay(onlineDay: [Int], blocks: Int, blockSize: Int) -> Int {
        guard blocks <= onlineDay.count / blockSize else { return -1 }
        var low = onlineDay.min()!
        var high = onlineDay.max()!                      // every panel is on: enough for all blocks
        while low < high {
            let mid = low + (high - low) / 2
            if blocksReady(onlineDay, on: mid, blockSize: blockSize) >= blocks {
                high = mid
            } else {
                low = mid + 1
            }
        }
        return low
    }

    /// How many separate blocks of `blockSize` adjacent online panels there are on `day`.
    private static func blocksReady(_ onlineDay: [Int], on day: Int, blockSize: Int) -> Int {
        var blocks = 0
        var run = 0
        for switchOn in onlineDay {
            if switchOn <= day {
                run += 1
                if run == blockSize {
                    blocks += 1
                    run = 0                              // these panels are used up
                }
            } else {
                run = 0                                  // an offline panel breaks the run
            }
        }
        return blocks
    }
}
