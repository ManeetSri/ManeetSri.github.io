// Reference solution: a k-d tree stored implicitly in an array of pin indices. The node for the range
// lo..<hi sits at its middle position, after quickselect has put that range's median by x (even depths)
// or y (odd depths) there, with smaller pins before it and larger ones after, so the tree is balanced.
// A query descends into the side the query is on first, then visits the other side only if the
// splitting line is no farther than the best distance so far. Ties go to the smallest index, so the
// other side is also visited when the line is exactly at the best distance and that side holds a
// smaller index (each node stores its subtree's smallest index). Building is O(n log n) on average;
// each query is close to O(log n) for typical data.

public enum NearestMapPin {
    public static func nearest(pins: [[Int]], queries: [[Int]]) -> [Int] {
        let xs = pins.map { $0[0] }
        let ys = pins.map { $0[1] }
        var order = Array(pins.indices)
        var smallestBelow = Array(repeating: Int.max, count: pins.count)   // by node position

        // Rearranges order[lo..<hi] so the median (by key, then index) is at the middle, with smaller
        // pins before it and larger ones after: quickselect, O(hi - lo) on average.
        func placeMedian(_ lo: Int, _ hi: Int, _ keys: [Int]) {
            func less(_ a: Int, _ b: Int) -> Bool { keys[a] != keys[b] ? keys[a] < keys[b] : a < b }
            let target = (lo + hi) / 2
            var low = lo, high = hi - 1
            while low < high {
                let pivot = order[(low + high) / 2]
                var i = low, j = high
                while i <= j {
                    while less(order[i], pivot) { i += 1 }
                    while less(pivot, order[j]) { j -= 1 }
                    if i <= j {
                        order.swapAt(i, j)
                        i += 1
                        j -= 1
                    }
                }
                if target <= j { high = j } else if target >= i { low = i } else { return }
            }
        }

        func build(_ lo: Int, _ hi: Int, _ depth: Int) -> Int {
            guard lo < hi else { return Int.max }
            placeMedian(lo, hi, depth % 2 == 0 ? xs : ys)
            let mid = (lo + hi) / 2
            let smallest = min(order[mid], build(lo, mid, depth + 1), build(mid + 1, hi, depth + 1))
            smallestBelow[mid] = smallest
            return smallest
        }
        _ = build(0, pins.count, 0)

        return queries.map { query in
            let qx = query[0], qy = query[1]
            var bestDistance = Int.max
            var bestIndex = Int.max

            func search(_ lo: Int, _ hi: Int, _ depth: Int) {
                guard lo < hi else { return }
                let mid = (lo + hi) / 2
                let pin = order[mid]
                let dx = xs[pin] - qx, dy = ys[pin] - qy
                let distance = dx * dx + dy * dy
                if distance < bestDistance || (distance == bestDistance && pin < bestIndex) {
                    bestDistance = distance
                    bestIndex = pin
                }
                let gap = depth % 2 == 0 ? qx - xs[pin] : qy - ys[pin]
                let (nearLo, nearHi, farLo, farHi) = gap < 0 ? (lo, mid, mid + 1, hi) : (mid + 1, hi, lo, mid)
                search(nearLo, nearHi, depth + 1)
                guard farLo < farHi else { return }
                let gapSquared = gap * gap
                if gapSquared < bestDistance || (gapSquared == bestDistance && smallestBelow[(farLo + farHi) / 2] < bestIndex) {
                    search(farLo, farHi, depth + 1)
                }
            }
            search(0, pins.count, 0)
            return bestIndex
        }
    }
}
