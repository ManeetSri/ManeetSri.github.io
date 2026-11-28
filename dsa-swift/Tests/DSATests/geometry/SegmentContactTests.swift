import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same segments
private struct ContactRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct SegmentContactTests {
    typealias Contact = SegmentContact.Contact

    /// A different method: solve A + t·r = C + u·s with exact fractions, and project collinear segments
    /// onto r with the dot product. Small coordinates only.
    private func reference(_ first: [[Int]], _ second: [[Int]]) -> Contact {
        let (ax, ay, bx, by) = (first[0][0], first[0][1], first[1][0], first[1][1])
        let (cx, cy, dx, dy) = (second[0][0], second[0][1], second[1][0], second[1][1])
        let (rx, ry, sx, sy) = (bx - ax, by - ay, dx - cx, dy - cy)
        let (qx, qy) = (cx - ax, cy - ay)
        func cross(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) -> Int { x1 * y2 - y1 * x2 }
        func dot(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) -> Int { x1 * x2 + y1 * y2 }
        let rIsPoint = rx == 0 && ry == 0, sIsPoint = sx == 0 && sy == 0

        if rIsPoint && sIsPoint {
            return ax == cx && ay == cy ? .point : .disjoint
        }
        if rIsPoint {        // is A on CD?
            let onLine = cross(ax - cx, ay - cy, sx, sy) == 0
            return onLine && dot(ax - cx, ay - cy, ax - dx, ay - dy) <= 0 ? .point : .disjoint
        }
        if sIsPoint {        // is C on AB?
            let onLine = cross(qx, qy, rx, ry) == 0
            return onLine && dot(cx - ax, cy - ay, cx - bx, cy - by) <= 0 ? .point : .disjoint
        }
        var denominator = cross(rx, ry, sx, sy)
        if denominator != 0 {
            var t = cross(qx, qy, sx, sy), u = cross(qx, qy, rx, ry)
            if denominator < 0 {
                denominator = -denominator
                t = -t
                u = -u
            }
            return 0 <= t && t <= denominator && 0 <= u && u <= denominator ? .point : .disjoint
        }
        if cross(qx, qy, rx, ry) != 0 {
            return .disjoint                       // parallel, on different lines
        }
        // Collinear: positions along r, where A is at 0 and B at r·r
        let length = dot(rx, ry, rx, ry)
        let p = dot(qx, qy, rx, ry), q = dot(dx - ax, dy - ay, rx, ry)
        let low = max(0, min(p, q)), high = min(length, max(p, q))
        if low < high { return .overlap }
        return low == high ? .point : .disjoint
    }

    @Test("Examples", arguments: [
        ([[0, 0], [4, 4]], [[0, 4], [4, 0]], Contact.point),        // a proper crossing
        ([[0, 0], [4, 0]], [[2, 0], [2, 5]], Contact.point),        // a T-junction
        ([[0, 0], [4, 0]], [[4, 0], [7, 3]], Contact.point),        // shared end
        ([[0, 0], [4, 0]], [[2, 0], [9, 0]], Contact.overlap),
        ([[0, 0], [4, 0]], [[4, 0], [9, 0]], Contact.point),        // collinear, touching at an end
        ([[0, 0], [4, 0]], [[5, 0], [9, 0]], Contact.disjoint),     // collinear, with a gap
        ([[0, 0], [4, 0]], [[0, 1], [4, 1]], Contact.disjoint),     // parallel
        ([[0, 0], [2, 2]], [[3, 0], [6, 3]], Contact.disjoint),
        ([[0, 0], [4, 4]], [[5, 0], [5, 9]], Contact.disjoint),     // would cross if AB were longer
        ([[1, 1], [1, 1]], [[0, 0], [2, 2]], Contact.point),        // a single point on a segment
        ([[3, 3], [3, 3]], [[0, 0], [2, 2]], Contact.disjoint),     // on the line, past the end
        ([[2, 5], [2, 5]], [[2, 5], [2, 5]], Contact.point),
        ([[2, 5], [2, 5]], [[5, 2], [5, 2]], Contact.disjoint),
        ([[0, 0], [0, 6]], [[0, 2], [0, 3]], Contact.overlap),      // vertical, one inside the other
        ([[0, 6], [0, 0]], [[0, 6], [0, 9]], Contact.point),
    ] as [([[Int]], [[Int]], Contact)])
    func examples(first: [[Int]], second: [[Int]], expected: Contact) {
        #expect(SegmentContact.contact(first, second) == expected)
        #expect(SegmentContact.contact(second, first) == expected)
        #expect(SegmentContact.contact([first[1], first[0]], [second[1], second[0]]) == expected)
    }

    @Test("Matches exact fractions on 3,000 random pairs, many of them collinear or single points")
    func randomSmall() {
        var random = ContactRandom(seed: 3)
        var seen: [Contact: Int] = [:]
        for _ in 0..<3_000 {
            let range = Int.random(in: 1...4, using: &random)
            let first = (0..<2).map { _ in [Int.random(in: -range...range, using: &random), Int.random(in: -range...range, using: &random)] }
            let second = (0..<2).map { _ in [Int.random(in: -range...range, using: &random), Int.random(in: -range...range, using: &random)] }
            let expected = reference(first, second)
            seen[expected, default: 0] += 1
            #expect(SegmentContact.contact(first, second) == expected)
        }
        #expect(seen.count == 3)     // the inputs really do include all three answers
    }

    @Test("Coordinates up to a billion, where the cross products are nearly 10¹⁹")
    func hugeCoordinates() {
        let big = 1_000_000_000
        #expect(SegmentContact.contact([[-big, -big], [big, big]], [[-big, big], [big, -big]]) == .point)
        #expect(SegmentContact.contact([[-big, -big], [big, big]], [[-big, -big + 1], [big, big]]) == .point)
        // Parallel diagonals one unit apart
        #expect(SegmentContact.contact([[-big, -big], [big, big - 1]], [[-big, -big + 1], [big, big]]) == .disjoint)
        #expect(SegmentContact.contact([[-big, -big], [big, big]], [[-big + 1, -big], [big, big - 1]]) == .disjoint)
        #expect(SegmentContact.contact([[-big, -big], [big, big]], [[0, 0], [big, big]]) == .overlap)
        #expect(SegmentContact.contact([[-big, big], [big, -big]], [[big, -big], [big, big]]) == .point)
        #expect(SegmentContact.contact([[-big, -big], [big, big]], [[1, 0], [big, big - 1]]) == .disjoint)
        #expect(SegmentContact.contact([[-big, -big], [big, big]], [[0, 1], [big, big - 1]]) == .point)
        // A short segment that crosses y = x at (big - 0.5, big - 0.5): just past the end of the first
        #expect(SegmentContact.contact([[-big, -big], [big - 1, big - 1]], [[big, big - 1], [big - 1, big]]) == .disjoint)
        #expect(SegmentContact.contact([[-big, -big], [big, big]], [[big, big - 1], [big - 1, big]]) == .point)
    }
}
