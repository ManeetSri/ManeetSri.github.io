import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CollinearPointsTests {
    @Test("Finds the best line", arguments: [
        ([[0, 0], [1, 1], [2, 2], [3, 1], [5, 5]], 4),
        ([[1, 4], [2, 3], [3, 2], [4, 1], [0, 0], [2, 2]], 4),
        ([[0, 0], [0, 7], [0, -3], [1, 1]], 3),
        ([[5, 2], [-1, 2], [9, 2], [0, 0], [3, 3]], 3),
        ([[0, 0], [1, 2], [2, 1]], 2),
        ([[0, 0], [3, 1], [6, 2], [1, 0], [9, 3]], 4),
    ])
    func finds(points: [[Int]], expected: Int) {
        #expect(CollinearPoints.maxOnOneLine(points) == expected)
    }

    @Test("Zero, one and two points")
    func smallInputs() {
        #expect(CollinearPoints.maxOnOneLine([]) == 0)
        #expect(CollinearPoints.maxOnOneLine([[4, -2]]) == 1)
        #expect(CollinearPoints.maxOnOneLine([[1, 1], [8, -3]]) == 2)
    }

    @Test("Repeated points count once per copy")
    func repeats() {
        #expect(CollinearPoints.maxOnOneLine([[2, 3], [2, 3], [2, 3]]) == 3)
        #expect(CollinearPoints.maxOnOneLine([[0, 0], [0, 0], [1, 1], [5, 0]]) == 3)
        #expect(CollinearPoints.maxOnOneLine([[1, 1], [2, 2], [1, 1], [0, 5], [2, 2]]) == 4)
    }

    @Test("Opposite directions are the same line")
    func oppositeDirections() {
        // From (0, 0), (2, -4) and (-1, 2) point opposite ways along the same line
        #expect(CollinearPoints.maxOnOneLine([[0, 0], [2, -4], [-1, 2], [3, 3]]) == 3)
    }

    @Test("Nearly equal slopes aren't confused, which floating-point slopes can get wrong")
    func nearlyParallel() {
        // Slopes 999,999,999/1,000,000,000 and 999,999,998/999,999,999 differ by about 1e-18,
        // less than a Double can tell apart
        let points = [[0, 0], [1_000_000_000, 999_999_999], [999_999_999, 999_999_998]]
        #expect(CollinearPoints.maxOnOneLine(points) == 2)
    }

    @Test("Stays fast on 1,000 points")
    func large() {
        // 600 points on y = 2x + 1, and 400 on the parabola y = x² (a line meets it at most twice)
        var points = (0..<600).map { [$0, 2 * $0 + 1] }
        points += (1...400).map { [-$0, $0 * $0] }
        #expect(CollinearPoints.maxOnOneLine(points) == 600)
        #expect(CollinearPoints.maxOnOneLine(Array(points.reversed())) == 600)
    }
}
