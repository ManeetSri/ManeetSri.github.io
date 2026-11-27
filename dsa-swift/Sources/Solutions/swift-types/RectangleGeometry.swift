// Reference solution: Rectangle geometry. Every property and method is O(1).

public enum RectangleGeometry {
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

        // Computed properties are recalculated on every read, so they never go stale
        public var area: Int {
            width * height
        }

        public var perimeter: Int {
            2 * (width + height)
        }

        public var isSquare: Bool {
            width == height
        }

        // Half-open on both axes: the left and top edges are inside, the right and bottom edges are not.
        // The parameters share names with the properties, so `self.x` means the rectangle's x.
        public func contains(x pointX: Int, y pointY: Int) -> Bool {
            (x..<x + width).contains(pointX) && (y..<y + height).contains(pointY)
        }
    }
}
