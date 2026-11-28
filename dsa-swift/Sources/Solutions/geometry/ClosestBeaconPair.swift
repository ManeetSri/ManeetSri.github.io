// Reference solution: Closest pair of beacons. A sweep line. Sort by x and sweep left to right, keeping
// the best squared distance so far, `best`, and a window of the points less than √best to the left
// (anything further can't do better). The window is a SortedSet ordered by (y, x), so the only points
// worth measuring, those within √best above or below, come out of one range query; the window can hold
// only a handful of them, because points that are all at least √best apart can't crowd into a
// √best by 2√best box. Squared distances stay exact in Int: coordinates up to 10⁹ give at most 8 × 10¹⁸.
// Two beacons on one spot give 0 at once, which also keeps the set free of duplicates.
// O(n log n) time, O(n) space.

import DSAKit

public enum ClosestBeaconPair {
    struct Point {
        var x: Int
        var y: Int
    }

    /// The window's ordering: by y, then x
    struct Key: Comparable {
        var y: Int
        var x: Int

        static func < (lhs: Key, rhs: Key) -> Bool {
            (lhs.y, lhs.x) < (rhs.y, rhs.x)
        }
    }

    static func squaredDistance(_ a: Point, _ b: Point) -> Int {
        (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)
    }

    /// The largest r with r * r ≤ value
    static func integerSquareRoot(_ value: Int) -> Int {
        var root = Int(Double(value).squareRoot())
        while root * root > value { root -= 1 }
        while (root + 1) * (root + 1) <= value { root += 1 }
        return root
    }

    public static func smallestSquaredDistance(_ beacons: [[Int]]) -> Int {
        let points = beacons.map { Point(x: $0[0], y: $0[1]) }.sorted { ($0.x, $0.y) < ($1.x, $1.y) }
        var best = squaredDistance(points[0], points[1])
        var window = SortedSet<Key>()
        var left = 0
        for p in points {
            if best == 0 {
                return 0
            }
            while (p.x - points[left].x) * (p.x - points[left].x) >= best {
                window.remove(Key(y: points[left].y, x: points[left].x))   // too far left to help
                left += 1
            }
            let reach = integerSquareRoot(best)       // only |dy| ≤ reach can give less than best
            let low = Key(y: p.y - reach, x: Int.min), high = Key(y: p.y + reach, x: Int.max)
            for q in window.elements(in: low...high) {
                best = min(best, squaredDistance(p, Point(x: q.x, y: q.y)))
            }
            window.insert(Key(y: p.y, x: p.x))
        }
        return best
    }
}
