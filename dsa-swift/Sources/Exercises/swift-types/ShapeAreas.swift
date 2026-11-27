// Problem: Shape areas (M09 · Enums, raw values and associated values)

public enum ShapeAreas {
    /// A shape and its measurements.
    public enum Shape: Equatable {
        case circle(radius: Double)
        case rectangle(width: Double, height: Double)
        case triangle(base: Double, height: Double)

        // Write your solution here, then run:
        // swift test --filter ShapeAreasTests

        /// The shape's area. Use `Double.pi` for circles.
        public var area: Double {
            return 0
        }
    }

    /// The sum of every shape's area, or 0 for no shapes.
    public static func totalArea(of shapes: [Shape]) -> Double {
        return 0
    }

    /// The shape with the largest area (the first one if several tie), or nil for no shapes.
    public static func largest(in shapes: [Shape]) -> Shape? {
        return nil
    }
}
