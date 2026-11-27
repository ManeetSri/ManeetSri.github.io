// Reference solution: Most points on one line. Fix each point as an anchor and group every later
// point by the direction from the anchor. A direction is the step (dx, dy) divided by its gcd, with
// the sign fixed so (2, -4) and (-1, 2) both become (1, -2): an exact Hashable key, unlike a Double
// slope. The best line through the anchor is its copies plus its biggest direction group. Lines are
// found from their first point, so later points only need to look forward. O(n²) time on average,
// O(n) space.

public enum CollinearPoints {
    private struct Direction: Hashable {
        let dx: Int
        let dy: Int

        init(dx: Int, dy: Int) {
            var divisor = Self.gcd(abs(dx), abs(dy))
            // Point the direction "rightwards", or straight up for a vertical line
            if dx < 0 || (dx == 0 && dy < 0) {
                divisor = -divisor
            }
            self.dx = dx / divisor
            self.dy = dy / divisor
        }

        private static func gcd(_ a: Int, _ b: Int) -> Int {
            b == 0 ? a : gcd(b, a % b)
        }
    }

    public static func maxOnOneLine(_ points: [[Int]]) -> Int {
        guard points.count > 2 else {
            return points.count
        }
        var best = 0
        for anchor in points.indices {
            var counts: [Direction: Int] = [:]
            var copies = 1
            var biggestGroup = 0
            for other in (anchor + 1)..<points.count {
                let dx = points[other][0] - points[anchor][0]
                let dy = points[other][1] - points[anchor][1]
                if dx == 0 && dy == 0 {
                    copies += 1
                    continue
                }
                let direction = Direction(dx: dx, dy: dy)
                counts[direction, default: 0] += 1
                biggestGroup = max(biggestGroup, counts[direction]!)
            }
            best = max(best, copies + biggestGroup)
        }
        return best
    }
}
