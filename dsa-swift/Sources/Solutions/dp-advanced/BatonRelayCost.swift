// Reference solution: The cheapest baton relay. cost[i] = fees[i] + the smallest cost[j] with
// i - longest ≤ j ≤ i - shortest, and that window slides one step right as i grows. Keep the window's
// candidates in a monotonic queue: indexes whose costs increase from front to back. At each i, the
// index i - shortest joins at the back (after dropping every candidate that's no cheaper than it),
// indexes older than i - longest leave from the front, and the front is the window's minimum.
// Unreachable checkpoints never join the queue. O(n) time, O(n) space.

public enum BatonRelayCost {
    public static func cheapestRelay(fees: [Int], shortest: Int, longest: Int) -> Int {
        let n = fees.count
        let unreachable = -1
        var cost = [Int](repeating: unreachable, count: n)
        cost[0] = fees[0]
        var queue = [Int](repeating: 0, count: n)       // a deque as an array with two ends
        var head = 0, tail = 0                          // queue[head..<tail] is live
        for i in 1..<max(n, 1) {
            let joining = i - shortest
            if joining >= 0 && cost[joining] != unreachable {
                while tail > head && cost[queue[tail - 1]] >= cost[joining] {
                    tail -= 1                           // never the cheapest again
                }
                queue[tail] = joining
                tail += 1
            }
            while tail > head && queue[head] < i - longest {
                head += 1                               // too far back to reach i
            }
            if tail > head {
                cost[i] = fees[i] + cost[queue[head]]
            }
        }
        return cost[n - 1]
    }
}
