// Reference solution: Ordering panels in bulk. First drop every panel that another panel covers (at
// least as wide and as tall): it can join that panel's batch for free. What's left, sorted by width,
// has widths rising and heights falling, and some optimal plan batches consecutive runs of it. A run
// j + 1...i costs width[i] × height[j + 1], so
//   best[i] = min over j < i of (height[j + 1] · width[i] + best[j]),
// the lowest of the lines y = height[j + 1] · x + best[j] at x = width[i]. Slopes fall as j grows and
// queries rise with i, so the convex hull trick with a pointer answers each query in amortised O(1).
// With sides up to 10^6, best[j] ≤ 10^12, so the cross-multiplied hull test stays below 10^18.
// O(n log n) for the sort, O(n) for the DP.

public enum PanelBulkOrders {
    public static func cheapestOrders(_ panels: [[Int]]) -> Int {
        // Widest first; among equal widths, tallest first. Keep a panel only if it's taller than every
        // panel kept so far, which are all at least as wide.
        let sorted = panels.sorted { ($0[0], $0[1]) > ($1[0], $1[1]) }
        var width: [Int] = [], height: [Int] = []
        for panel in sorted where panel[1] > (height.last ?? 0) {
            width.append(panel[0])
            height.append(panel[1])
        }
        width.reverse()                                // widths rising, heights falling
        height.reverse()
        let n = width.count
        if n == 0 { return 0 }

        var slopes: [Int] = [], intercepts: [Int] = []
        var front = 0
        func value(_ line: Int, _ x: Int) -> Int { slopes[line] * x + intercepts[line] }
        func add(_ m: Int, _ c: Int) {
            while slopes.count - front >= 2 {
                let a = slopes.count - 2, b = slopes.count - 1
                // b is useless if the new line overtakes a no later than b does
                if (c - intercepts[a]) * (slopes[a] - slopes[b]) <= (intercepts[b] - intercepts[a]) * (slopes[a] - m) {
                    slopes.removeLast()
                    intercepts.removeLast()
                } else {
                    break
                }
            }
            slopes.append(m)
            intercepts.append(c)
        }

        var best = 0                                   // best[0]: no panels, no cost
        add(height[0], 0)                              // j = 0: the next batch starts at panel 0
        for i in 0..<n {
            let x = width[i]
            while front + 1 < slopes.count && value(front + 1, x) <= value(front, x) {
                front += 1
            }
            best = value(front, x)                     // best for panels 0...i
            if i + 1 < n {
                add(height[i + 1], best)               // j = i + 1: a batch starting at panel i + 1
            }
        }
        return best
    }
}
