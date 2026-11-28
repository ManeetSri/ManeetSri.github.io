// Reference solution: Covered floor area. Sweep a vertical line from left to right. Each rug becomes
// two events: at x1 its y-range [y1, y2) gains one layer of cover, and at x2 it loses one. Between two
// consecutive event positions the covered length of the sweep line is constant, so the area there is
// that length times the gap. Compress the distinct y values into slabs, and keep a segment tree over
// the slabs that stores, per node, how many rugs cover its whole range and how much of its range is
// covered. A range that is wholly covered counts fully; otherwise its length comes from its children.
// Adds and removes come in matching pairs, so counts never need pushing down. Areas stay in Int:
// coordinates up to 10⁹ give at most 10¹⁸. O(n log n) time, O(n) space.

public enum CoveredFloorArea {
    public static func coveredArea(_ rugs: [[Int]]) -> Int {
        var ys: [Int] = []
        var events: [(x: Int, low: Int, high: Int, change: Int)] = []
        for rug in rugs where rug[0] < rug[2] && rug[1] < rug[3] {     // flat rugs cover nothing
            ys.append(rug[1])
            ys.append(rug[3])
            events.append((rug[0], rug[1], rug[3], 1))
            events.append((rug[2], rug[1], rug[3], -1))
        }
        guard !events.isEmpty else { return 0 }
        ys = Array(Set(ys)).sorted()
        var slabOf: [Int: Int] = [:]                  // y value → index into ys
        for (index, y) in ys.enumerated() {
            slabOf[y] = index
        }
        events.sort { $0.x < $1.x }

        // Node `node` covers slabs lo..<hi, which span ys[lo] to ys[hi]
        let slabs = ys.count - 1
        var cover = [Int](repeating: 0, count: 4 * slabs)
        var covered = [Int](repeating: 0, count: 4 * slabs)
        func update(_ node: Int, _ lo: Int, _ hi: Int, _ from: Int, _ to: Int, _ change: Int) {
            if to <= lo || hi <= from {
                return
            }
            if from <= lo && hi <= to {
                cover[node] += change
            } else {
                let mid = (lo + hi) / 2
                update(2 * node, lo, mid, from, to, change)
                update(2 * node + 1, mid, hi, from, to, change)
            }
            if cover[node] > 0 {
                covered[node] = ys[hi] - ys[lo]
            } else if hi - lo == 1 {
                covered[node] = 0
            } else {
                covered[node] = covered[2 * node] + covered[2 * node + 1]
            }
        }

        var area = 0
        var previousX = events[0].x
        for event in events {
            area += covered[1] * (event.x - previousX)  // the strip since the last event
            previousX = event.x
            update(1, 0, slabs, slabOf[event.low]!, slabOf[event.high]!, event.change)
        }
        return area
    }
}
