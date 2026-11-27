// Problem: Shapes: some or any? (M10 · some vs any)

public enum SomeOrAnyShapes {
    public protocol Shape {
        var name: String { get }
        func area() -> Double
    }

    public struct Square: Shape {
        public let side: Double

        public init(side: Double) {
            self.side = side
        }

        public var name: String { "square" }

        public func area() -> Double {
            side * side
        }
    }

    public struct Rectangle: Shape {
        public let width: Double
        public let height: Double

        public init(width: Double, height: Double) {
            self.width = width
            self.height = height
        }

        public var name: String { "rectangle" }

        public func area() -> Double {
            width * height
        }
    }

    public struct Circle: Shape {
        public let radius: Double

        public init(radius: Double) {
            self.radius = radius
        }

        public var name: String { "circle" }

        public func area() -> Double {
            Double.pi * radius * radius
        }
    }

    /// Reads "square 3", "rectangle 2 5" or "circle 1.5": a lowercase name, then its measurements,
    /// separated by spaces. Nil if the name is unknown, the number of measurements is wrong, or a
    /// measurement isn't a positive number.
    public static func parse(_ line: String) -> (any Shape)? {
        // Write your solution here, then run:
        // swift test --filter SomeOrAnyShapesTests
        return nil
    }

    /// The total area of the lines that parse. Lines that don't parse are skipped.
    public static func totalArea(of lines: [String]) -> Double {
        return 0
    }

    /// Whichever of two shapes of the same type has the larger area; the first one on a tie.
    public static func larger<S: Shape>(_ first: S, _ second: S) -> S {
        return second
    }

    /// Squares with sides 1, 2, 3, ..., count, in that order. Nothing when `count` is 0.
    public static func squareTiles(count: Int) -> some Sequence<Square> {
        return [Square]()
    }
}
