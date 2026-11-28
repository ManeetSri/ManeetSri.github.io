import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RectangleGeometryTests {
    typealias Rectangle = RectangleGeometry.Rectangle

    @Test("Area and perimeter", arguments: [
        (4, 3, 12, 14),
        (5, 5, 25, 20),
        (1, 1, 1, 4),
        (0, 7, 0, 14),
        (10_000, 10_000, 100_000_000, 40_000),
    ])
    func areaAndPerimeter(width: Int, height: Int, area: Int, perimeter: Int) {
        let rectangle = Rectangle(x: 0, y: 0, width: width, height: height)
        #expect(rectangle.area == area)
        #expect(rectangle.perimeter == perimeter)
    }

    @Test("Spots squares", arguments: [(5, 5, true), (4, 3, false), (3, 4, false), (0, 0, true)])
    func squares(width: Int, height: Int, expected: Bool) {
        #expect(Rectangle(x: 2, y: 2, width: width, height: height).isSquare == expected)
    }

    @Test("Computed properties follow changes to the stored ones")
    func staysUpToDate() {
        var rectangle = Rectangle(x: 0, y: 0, width: 2, height: 3)
        #expect(rectangle.area == 6)
        rectangle.width = 3
        #expect(rectangle.area == 9)
        #expect(rectangle.perimeter == 12)
        #expect(rectangle.isSquare)
    }

    @Test("Left and top edges are inside, right and bottom edges are not", arguments: [
        (2, 1, true),
        (4, 2, true),
        (3, 1, true),
        (5, 1, false),
        (2, 3, false),
        (1, 1, false),
        (3, 0, false),
        (5, 3, false),
    ])
    func containsPoints(pointX: Int, pointY: Int, expected: Bool) {
        let rectangle = Rectangle(x: 2, y: 1, width: 3, height: 2)
        #expect(rectangle.contains(x: pointX, y: pointY) == expected)
    }

    @Test("Works with negative coordinates")
    func negativeCoordinates() {
        let rectangle = Rectangle(x: -5, y: -5, width: 10, height: 10)
        #expect(rectangle.contains(x: 0, y: 0))
        #expect(rectangle.contains(x: -5, y: -5))
        #expect(rectangle.contains(x: 4, y: 4))
        #expect(!rectangle.contains(x: 5, y: 5))
        #expect(!rectangle.contains(x: -6, y: 0))
    }

    @Test("A rectangle with no width or height contains nothing")
    func empty() {
        #expect(!Rectangle(x: 0, y: 0, width: 0, height: 5).contains(x: 0, y: 0))
        #expect(!Rectangle(x: 0, y: 0, width: 5, height: 0).contains(x: 0, y: 0))
    }
}
