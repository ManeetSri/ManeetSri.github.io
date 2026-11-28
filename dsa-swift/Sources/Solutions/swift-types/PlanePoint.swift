// Reference solution: Point on a plane. Every method is O(1).

public enum PlanePoint {
    public struct Point {
        public var x: Int
        public var y: Int

        public init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }

        // Changes this point, so it must be `mutating`
        public mutating func move(dx: Int, dy: Int) {
            x += dx
            y += dy
        }

        // Leaves this point alone and returns a moved copy, reusing `move` on a local copy
        public func moved(dx: Int, dy: Int) -> Point {
            var copy = self
            copy.move(dx: dx, dy: dy)
            return copy
        }

        public func manhattanDistance(to other: Point) -> Int {
            abs(other.x - x) + abs(other.y - y)
        }

        public func distance(to other: Point) -> Double {
            let dx = Double(other.x - x)
            let dy = Double(other.y - y)
            return (dx * dx + dy * dy).squareRoot()
        }
    }
}
