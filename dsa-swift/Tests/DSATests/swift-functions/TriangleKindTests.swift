import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TriangleKindTests {
    @Test("Three equal sides", arguments: [(3, 3, 3), (1, 1, 1), (1_000_000, 1_000_000, 1_000_000)])
    func equilateral(a: Int, b: Int, c: Int) {
        #expect(TriangleKind.kind(a: a, b: b, c: c) == "equilateral")
    }

    @Test("Exactly two equal sides, in any position", arguments: [
        (5, 5, 8), (5, 8, 5), (8, 5, 5), (2, 2, 3), (10, 10, 1),
    ])
    func isosceles(a: Int, b: Int, c: Int) {
        #expect(TriangleKind.kind(a: a, b: b, c: c) == "isosceles")
    }

    @Test("All sides different, longest in any position", arguments: [
        (3, 4, 5), (5, 3, 4), (4, 5, 3), (7, 10, 5), (2, 3, 4),
    ])
    func scalene(a: Int, b: Int, c: Int) {
        #expect(TriangleKind.kind(a: a, b: b, c: c) == "scalene")
    }

    @Test("Flat triangles are invalid", arguments: [(1, 2, 3), (3, 1, 2), (2, 3, 1), (5, 5, 10), (0, 0, 0)])
    func flat(a: Int, b: Int, c: Int) {
        #expect(TriangleKind.kind(a: a, b: b, c: c) == "invalid")
    }

    @Test("Two equal sides that can't reach are invalid, not isosceles", arguments: [
        (2, 2, 5), (5, 2, 2), (1, 1, 1_000_000),
    ])
    func tooShort(a: Int, b: Int, c: Int) {
        #expect(TriangleKind.kind(a: a, b: b, c: c) == "invalid")
    }

    @Test("Zero or negative sides are invalid", arguments: [
        (0, 4, 4), (4, 0, 4), (4, 4, 0), (-3, 4, 5), (3, -4, 5), (-1, -1, -1), (-1_000_000, 5, 5),
    ])
    func nonPositive(a: Int, b: Int, c: Int) {
        #expect(TriangleKind.kind(a: a, b: b, c: c) == "invalid")
    }

    @Test("Very long, thin triangles are still valid")
    func thin() {
        #expect(TriangleKind.kind(a: 1_000_000, b: 1_000_000, c: 1) == "isosceles")
        #expect(TriangleKind.kind(a: 999_999, b: 1_000_000, c: 2) == "scalene")
    }
}
