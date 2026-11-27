import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ShapeAreasTests {
    typealias Shape = ShapeAreas.Shape

    private static func isClose(_ value: Double, _ expected: Double) -> Bool {
        abs(value - expected) < 1e-9
    }

    @Test("Circle areas use pi")
    func circles() {
        #expect(Self.isClose(Shape.circle(radius: 1).area, Double.pi))
        #expect(Self.isClose(Shape.circle(radius: 2).area, 4 * Double.pi))
        #expect(Self.isClose(Shape.circle(radius: 0).area, 0))
    }

    @Test("Rectangle areas")
    func rectangles() {
        #expect(Self.isClose(Shape.rectangle(width: 3, height: 4).area, 12))
        #expect(Self.isClose(Shape.rectangle(width: 2.5, height: 2).area, 5))
    }

    @Test("Triangle areas are half of base times height")
    func triangles() {
        #expect(Self.isClose(Shape.triangle(base: 6, height: 4).area, 12))
        #expect(Self.isClose(Shape.triangle(base: 3, height: 3).area, 4.5))
    }

    @Test("Total area adds every shape")
    func total() {
        let shapes: [Shape] = [.rectangle(width: 2, height: 3), .triangle(base: 4, height: 5), .circle(radius: 1)]
        #expect(Self.isClose(ShapeAreas.totalArea(of: shapes), 16 + Double.pi))
    }

    @Test("Total area of no shapes is 0")
    func totalEmpty() {
        #expect(ShapeAreas.totalArea(of: []) == 0)
    }

    @Test("Finds the largest shape")
    func largest() {
        let shapes: [Shape] = [.circle(radius: 1), .rectangle(width: 2, height: 3), .triangle(base: 10, height: 1)]
        #expect(ShapeAreas.largest(in: shapes) == .rectangle(width: 2, height: 3))
        #expect(ShapeAreas.largest(in: [.circle(radius: 10), .rectangle(width: 10, height: 10)]) == .circle(radius: 10))
    }

    @Test("The first of several equally large shapes wins")
    func largestTie() {
        let shapes: [Shape] = [.triangle(base: 1, height: 1), .rectangle(width: 2, height: 2), .triangle(base: 4, height: 2)]
        #expect(ShapeAreas.largest(in: shapes) == .rectangle(width: 2, height: 2))
    }

    @Test("Single shape and no shapes")
    func largestEdges() {
        #expect(ShapeAreas.largest(in: [.circle(radius: 3)]) == .circle(radius: 3))
        #expect(ShapeAreas.largest(in: []) == nil)
    }
}
