// Reference solution: The two nearest drones. Closest pair by divide and conquer, on squared distances
// so everything stays an exact Int. Sort by x and split at the middle; the answer is in the left half,
// the right half, or a pair straddling the dividing line. With best = the smaller half answer, a closer
// straddling pair must have both points within the strip dx² < best, and in y order each point only
// needs the following points with dy² < best (at most 7 of them). Each call also merges its range by y,
// as merge sort does, so the strip never needs sorting: T(n) = 2T(n/2) + n, O(n log n) time, O(n) space.

public enum NearestDronePair {
    private struct Point {
        let x: Int
        let y: Int
    }

    public static func smallestSquaredDistance(_ drones: [[Int]]) -> Int {
        var points = drones.map { Point(x: $0[0], y: $0[1]) }
        points.sort { $0.x != $1.x ? $0.x < $1.x : $0.y < $1.y }
        var buffer = points
        var strip: [Point] = []
        strip.reserveCapacity(points.count)
        return closest(&points, &buffer, &strip, 0, points.count)
    }

    private static func squaredDistance(_ a: Point, _ b: Point) -> Int {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return dx * dx + dy * dy
    }

    /// The smallest squared distance in points[low..<high], which arrive sorted by x and leave sorted by y.
    private static func closest(_ points: inout [Point], _ buffer: inout [Point], _ strip: inout [Point],
                                _ low: Int, _ high: Int) -> Int {
        if high - low <= 3 {
            var best = Int.max
            for i in low..<high {
                for j in (i + 1)..<high {
                    best = min(best, squaredDistance(points[i], points[j]))
                }
            }
            points[low..<high].sort { $0.y < $1.y }
            return best
        }
        let mid = low + (high - low) / 2
        let lineX = points[mid].x                         // before the calls re-sort the range by y
        var best = min(closest(&points, &buffer, &strip, low, mid), closest(&points, &buffer, &strip, mid, high))

        for index in low..<high {
            buffer[index] = points[index]
        }
        var left = low
        var right = mid
        for write in low..<high {
            if right == high || (left < mid && buffer[left].y <= buffer[right].y) {
                points[write] = buffer[left]
                left += 1
            } else {
                points[write] = buffer[right]
                right += 1
            }
        }

        strip.removeAll(keepingCapacity: true)
        for index in low..<high {
            let dx = points[index].x - lineX
            if dx * dx < best {
                strip.append(points[index])
            }
        }
        for i in strip.indices {
            var j = i + 1
            while j < strip.count {
                let dy = strip[j].y - strip[i].y
                if dy * dy >= best { break }
                best = min(best, squaredDistance(strip[i], strip[j]))
                j += 1
            }
        }
        return best
    }
}
