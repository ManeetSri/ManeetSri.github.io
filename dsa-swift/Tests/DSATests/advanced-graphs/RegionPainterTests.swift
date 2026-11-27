import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RegionPainterTests {
    /// True when `colours` gives each of the n regions a colour in 0..<m and bordering regions differ.
    private func isValid(_ colours: [Int], _ n: Int, _ borders: [[Int]], _ m: Int) -> Bool {
        colours.count == n
            && colours.allSatisfy { (0..<m).contains($0) }
            && borders.allSatisfy { colours[$0[0]] != colours[$0[1]] }
    }

    private static func cycle(_ n: Int, from first: Int = 0) -> [[Int]] {
        (0..<n).map { [first + $0, first + ($0 + 1) % n] }
    }

    private static func complete(_ n: Int) -> [[Int]] {
        (0..<n).flatMap { a in (a + 1..<n).map { [a, $0] } }
    }

    // Outer five-cycle 0–4, spokes i–(i + 5), inner five-pointed star on 5–9. Needs exactly 3 colours.
    private static let petersen: [[Int]] = cycle(5) + (0..<5).map { [$0, $0 + 5] } + [[5, 7], [7, 9], [9, 6], [6, 8], [8, 5]]

    // The Grötzsch graph: a five-cycle 0–4, a shadow i + 5 of each i joined to i's neighbours, and
    // region 10 joined to every shadow. It has no triangle, yet needs 4 colours.
    private static let grotzsch: [[Int]] = {
        var borders = cycle(5)
        for i in 0..<5 {
            borders += [[i + 5, (i + 4) % 5], [i + 5, (i + 1) % 5], [i + 5, 10]]
        }
        return borders
    }()

    // A hub (region 0) inside a ring of regions 1...rim
    private static func wheel(rim: Int) -> [[Int]] {
        cycle(rim, from: 1) + (1...rim).map { [0, $0] }
    }

    @Test("Colourable maps", arguments: [
        (3, [[0, 1], [1, 2], [2, 0]], 3),
        (4, cycle(4), 2),
        (6, cycle(6), 2),
        (5, cycle(5), 3),
        (10, petersen, 3),
        (11, grotzsch, 4),
        (5, wheel(rim: 4), 3),
        (6, wheel(rim: 5), 4),
        (5, complete(5), 5),
        (4, [], 1),
        (1, [], 1),
        (3, [[0, 1]], 4),
    ] as [(Int, [[Int]], Int)])
    func colourable(n: Int, borders: [[Int]], m: Int) {
        let colours = RegionPainter.colour(n, borders, colours: m)
        #expect(colours != nil)
        if let colours {
            #expect(isValid(colours, n, borders, m))
        }
    }

    @Test("Not enough colours", arguments: [
        (4, complete(4), 3),
        (5, cycle(5), 2),
        (10, petersen, 2),
        (11, grotzsch, 3),
        (6, wheel(rim: 5), 3),
        (6, complete(6), 5),
        (2, [[0, 1]], 1),
        (3, [[0, 1]], 0),
    ] as [(Int, [[Int]], Int)])
    func notColourable(n: Int, borders: [[Int]], m: Int) {
        #expect(RegionPainter.colour(n, borders, colours: m) == nil)
    }

    @Test("A 4 × 4 grid of regions needs only 2 colours")
    func grid() {
        var borders: [[Int]] = []
        for row in 0..<4 {
            for column in 0..<4 {
                let region = row * 4 + column
                if column < 3 { borders.append([region, region + 1]) }
                if row < 3 { borders.append([region, region + 4]) }
            }
        }
        let colours = RegionPainter.colour(16, borders, colours: 2)
        #expect(colours != nil)
        if let colours {
            #expect(isValid(colours, 16, borders, 2))
        }
        #expect(RegionPainter.colour(16, borders + [[0, 5]], colours: 2) == nil)
    }

    @Test("Easy regions first, an impossible corner last")
    func impossibleCornerLast() {
        // Regions 0–11 form a path, which 3 colours handle in many ways; regions 12–15 border each
        // other, so every one of those ways fails at the end
        let path: [[Int]] = (0..<11).map { [$0, $0 + 1] }
        let corner: [[Int]] = Self.complete(4).map { [$0[0] + 12, $0[1] + 12] }
        let borders = path + corner + [[11, 12]]
        #expect(RegionPainter.colour(16, borders, colours: 3) == nil)
        let colours = RegionPainter.colour(16, borders, colours: 4)
        #expect(colours != nil)
        if let colours {
            #expect(isValid(colours, 16, borders, 4))
        }
    }
}
