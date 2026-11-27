// Reference solution: Shape areas. `area` is O(1); `totalArea` and `largest` are one pass, O(n).

public enum ShapeAreas {
    public enum Shape: Equatable {
        case circle(radius: Double)
        case rectangle(width: Double, height: Double)
        case triangle(base: Double, height: Double)

        // One switch case per enum case, binding each case's associated values
        public var area: Double {
            switch self {
            case .circle(let radius):
                return Double.pi * radius * radius
            case let .rectangle(width, height):
                return width * height
            case let .triangle(base, height):
                return base * height / 2
            }
        }
    }

    public static func totalArea(of shapes: [Shape]) -> Double {
        shapes.reduce(0) { $0 + $1.area }
    }

    // Replaces the best only on a strictly larger area, so the first of several ties wins
    public static func largest(in shapes: [Shape]) -> Shape? {
        guard var best = shapes.first else { return nil }
        for shape in shapes.dropFirst() where shape.area > best.area {
            best = shape
        }
        return best
    }
}
