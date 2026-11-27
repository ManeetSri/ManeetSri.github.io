import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PlanePointTests {
    typealias Point = PlanePoint.Point

    private static func isClose(_ value: Double, _ expected: Double) -> Bool {
        abs(value - expected) < 1e-9
    }

    @Test("move changes the point itself")
    func move() {
        var point = Point(x: 1, y: 2)
        point.move(dx: 3, dy: -4)
        #expect(point.x == 4)
        #expect(point.y == -2)
        point.move(dx: -10, dy: 0)
        #expect(point.x == -6)
        #expect(point.y == -2)
    }

    @Test("Moving by zero changes nothing")
    func moveByZero() {
        var point = Point(x: 7, y: -3)
        point.move(dx: 0, dy: 0)
        #expect(point.x == 7)
        #expect(point.y == -3)
    }

    @Test("moved returns a new point and leaves the original alone")
    func moved() {
        let start = Point(x: 5, y: 5)
        let end = start.moved(dx: -2, dy: 10)
        #expect(end.x == 3)
        #expect(end.y == 15)
        #expect(start.x == 5)
        #expect(start.y == 5)
    }

    @Test("Manhattan distance", arguments: [
        (0, 0, 3, 4, 7),
        (-2, 5, 1, -1, 9),
        (6, 6, 6, 6, 0),
        (-1_000_000, -1_000_000, 1_000_000, 1_000_000, 4_000_000),
    ])
    func manhattan(x1: Int, y1: Int, x2: Int, y2: Int, expected: Int) {
        let a = Point(x: x1, y: y1)
        let b = Point(x: x2, y: y2)
        #expect(a.manhattanDistance(to: b) == expected)
        #expect(b.manhattanDistance(to: a) == expected)
    }

    @Test("Straight-line distance", arguments: [
        (0, 0, 3, 4, 5.0),
        (1, 1, 4, 5, 5.0),
        (-3, 0, 3, 8, 10.0),
        (2, 2, 2, 2, 0.0),
        (0, 0, 1, 1, 2.0.squareRoot()),
    ])
    func distance(x1: Int, y1: Int, x2: Int, y2: Int, expected: Double) {
        let a = Point(x: x1, y: y1)
        let b = Point(x: x2, y: y2)
        #expect(Self.isClose(a.distance(to: b), expected))
        #expect(Self.isClose(b.distance(to: a), expected))
    }
}
