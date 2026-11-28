// Reference solution: Shapes: some or any? parse can return three different types, so it needs a box,
// any Shape. larger needs both shapes to be the same type, so it's generic. squareTiles always returns
// one type, so it hides it behind some. parse is O(L) for a line of length L; the others are O(n).

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

    public static func parse(_ line: String) -> (any Shape)? {
        let words = line.split(separator: " ")
        guard let kind = words.first else {
            return nil
        }
        var sizes: [Double] = []
        for word in words.dropFirst() {
            guard let size = Double(word), size > 0 else {
                return nil
            }
            sizes.append(size)
        }
        switch (kind, sizes.count) {
        case ("square", 1):
            return Square(side: sizes[0])
        case ("rectangle", 2):
            return Rectangle(width: sizes[0], height: sizes[1])
        case ("circle", 1):
            return Circle(radius: sizes[0])
        default:
            return nil
        }
    }

    public static func totalArea(of lines: [String]) -> Double {
        var total = 0.0
        for line in lines {
            if let shape = parse(line) {
                total += shape.area()
            }
        }
        return total
    }

    public static func larger<S: Shape>(_ first: S, _ second: S) -> S {
        second.area() > first.area() ? second : first
    }

    public static func squareTiles(count: Int) -> some Sequence<Square> {
        (0..<max(count, 0)).map { Square(side: Double($0 + 1)) }
    }
}
