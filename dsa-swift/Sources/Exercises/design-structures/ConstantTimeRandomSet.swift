// Problem: Constant-time random set (M72 · RandomizedSet: insert, delete, getRandom in O(1))

public enum ConstantTimeRandomSet {
    /// A set that can also hand back a uniformly random element. Every operation is O(1) on average.
    public struct RandomSet<Element: Hashable> {
        // Write your solution here, then run:
        // swift test --filter ConstantTimeRandomSetTests
        // Add whatever private storage you need.

        /// Creates an empty set.
        public init() {
        }

        /// The number of elements.
        public var count: Int {
            return 0
        }

        /// True when the set holds no elements.
        public var isEmpty: Bool {
            return true
        }

        /// True if `element` is in the set.
        public func contains(_ element: Element) -> Bool {
            return false
        }

        /// Adds `element` and returns true, or returns false if it was already there.
        @discardableResult
        public mutating func insert(_ element: Element) -> Bool {
            return false
        }

        /// Removes `element` and returns true, or returns false if it wasn't there.
        @discardableResult
        public mutating func remove(_ element: Element) -> Bool {
            return false
        }

        /// A uniformly random element, chosen with `generator`, or nil if the set is empty.
        public func randomElement<G: RandomNumberGenerator>(using generator: inout G) -> Element? {
            return nil
        }

        /// A uniformly random element, chosen with the system's generator, or nil if the set is empty.
        public func randomElement() -> Element? {
            return nil
        }
    }
}
