// Problem: Rectangle geometry (M09 · Structs, properties and methods)

public enum RectangleGeometry {
    /// A rectangle on a grid. (x, y) is its top-left corner; x grows to the right and y grows downwards.
    public struct Rectangle {
        public var x: Int
        public var y: Int
        public var width: Int
        public var height: Int

        public init(x: Int, y: Int, width: Int, height: Int) {
            self.x = x
            self.y = y
            self.width = width
            self.height = height
        }

        // Write your solution here, then run:
        // swift test --filter RectangleGeometryTests

        /// Width times height.
        public var area: Int {
            return 0
        }

        /// The distance all the way round: twice the width plus twice the height.
        public var perimeter: Int {
            return 0
        }

        /// True when the width equals the height.
        public var isSquare: Bool {
            return false
        }

        /// True when the point is inside. The left and top edges count as inside; the right and
        /// bottom edges (x + width and y + height) do not.
        public func contains(x pointX: Int, y pointY: Int) -> Bool {
            return false
        }
    }
}
