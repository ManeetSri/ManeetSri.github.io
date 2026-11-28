// Problem: Point on a plane (M09 · mutating methods and initialisers)

public enum PlanePoint {
    /// A point with whole-number coordinates.
    public struct Point {
        public var x: Int
        public var y: Int

        public init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }

        // Write your solution here, then run:
        // swift test --filter PlanePointTests

        /// Moves this point by dx horizontally and dy vertically.
        public mutating func move(dx: Int, dy: Int) {
        }

        /// Returns a new point moved by dx and dy, leaving this one unchanged.
        public func moved(dx: Int, dy: Int) -> Point {
            return self
        }

        /// The number of horizontal plus vertical steps between the two points.
        public func manhattanDistance(to other: Point) -> Int {
            return 0
        }

        /// The straight-line distance between the two points.
        public func distance(to other: Point) -> Double {
            return 0
        }
    }
}
