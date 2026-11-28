import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct SomeOrAnyShapesTests {
    typealias Square = SomeOrAnyShapes.Square
    typealias Rectangle = SomeOrAnyShapes.Rectangle
    typealias Circle = SomeOrAnyShapes.Circle

    private static func isClose(_ value: Double, _ expected: Double) -> Bool {
        abs(value - expected) < 1e-9
    }

    @Test("Each word parses into its own type")
    func parsesTypes() throws {
        let square = try #require(SomeOrAnyShapes.parse("square 3") as? Square)
        #expect(square.side == 3)

        let rectangle = try #require(SomeOrAnyShapes.parse("rectangle 2 5") as? Rectangle)
        #expect(rectangle.width == 2)
        #expect(rectangle.height == 5)

        let circle = try #require(SomeOrAnyShapes.parse("circle 1.5") as? Circle)
        #expect(circle.radius == 1.5)
    }

    @Test("Parsed shapes work through the protocol", arguments: [
        ("square 3", "square", 9.0),
        ("rectangle 2 5", "rectangle", 10.0),
        ("rectangle 0.5 3", "rectangle", 1.5),
        ("circle 1", "circle", Double.pi),
        ("circle 2", "circle", 4 * Double.pi),
    ])
    func parsedThroughProtocol(line: String, name: String, area: Double) throws {
        let shape = try #require(SomeOrAnyShapes.parse(line))
        #expect(shape.name == name)
        #expect(Self.isClose(shape.area(), area))
    }

    @Test("Lines that don't describe a shape give nil", arguments: [
        "", "hexagon 2", "square", "square 2 3", "rectangle 4", "circle 1 1",
        "square x", "rectangle 2 two", "square 0", "circle -1", "rectangle 3 -2", "Square 3",
    ])
    func invalid(line: String) {
        #expect(SomeOrAnyShapes.parse(line) == nil)
    }

    @Test("totalArea adds the shapes that parse and skips the rest")
    func totalArea() {
        #expect(Self.isClose(SomeOrAnyShapes.totalArea(of: ["square 1", "rectangle 2 3", "square 2"]), 11))
        #expect(Self.isClose(SomeOrAnyShapes.totalArea(of: ["square 2", "triangle 3", "circle 1", "square -4"]), 4 + Double.pi))
        #expect(SomeOrAnyShapes.totalArea(of: []) == 0)
        #expect(SomeOrAnyShapes.totalArea(of: ["nonsense"]) == 0)
    }

    @Test("larger returns the bigger of two shapes of the same type")
    func larger() {
        #expect(SomeOrAnyShapes.larger(Square(side: 2), Square(side: 3)).side == 3)
        #expect(SomeOrAnyShapes.larger(Square(side: 5), Square(side: 3)).side == 5)
        let wide = Rectangle(width: 6, height: 1)
        let tall = Rectangle(width: 2, height: 4)
        #expect(SomeOrAnyShapes.larger(wide, tall).width == 2)
        #expect(SomeOrAnyShapes.larger(Circle(radius: 1), Circle(radius: 0.5)).radius == 1)
    }

    @Test("On a tie, larger returns the first shape")
    func largerTie() {
        let first = Rectangle(width: 2, height: 3)
        let second = Rectangle(width: 3, height: 2)
        #expect(SomeOrAnyShapes.larger(first, second).width == 2)
        #expect(SomeOrAnyShapes.larger(second, first).width == 3)
    }

    @Test("squareTiles gives squares with sides 1 to count")
    func squareTiles() {
        #expect(SomeOrAnyShapes.squareTiles(count: 4).map { $0.side } == [1, 2, 3, 4])
        #expect(SomeOrAnyShapes.squareTiles(count: 1).map { $0.area() } == [1])
        #expect(Array(SomeOrAnyShapes.squareTiles(count: 0)).isEmpty)
        #expect(SomeOrAnyShapes.squareTiles(count: 100).reduce(0) { $0 + $1.area() } == 338_350)
    }
}
