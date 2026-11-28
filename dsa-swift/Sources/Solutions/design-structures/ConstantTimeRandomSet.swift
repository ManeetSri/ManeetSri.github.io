// Reference solution: Constant-time random set. An array holds the elements, so a random position
// is one random number away, and a dictionary maps each element to its position, so membership and
// removal can find it. Removing swaps the last element into the hole, so the array never shifts.
// Every operation is O(1) on average.

public enum ConstantTimeRandomSet {
    public struct RandomSet<Element: Hashable> {
        private var elements: [Element] = []
        private var positions: [Element: Int] = [:]

        public init() {}

        public var count: Int {
            elements.count
        }

        public var isEmpty: Bool {
            elements.isEmpty
        }

        public func contains(_ element: Element) -> Bool {
            positions[element] != nil
        }

        @discardableResult
        public mutating func insert(_ element: Element) -> Bool {
            guard positions[element] == nil else { return false }
            positions[element] = elements.count
            elements.append(element)
            return true
        }

        @discardableResult
        public mutating func remove(_ element: Element) -> Bool {
            guard let hole = positions.removeValue(forKey: element) else { return false }
            let last = elements.removeLast()
            if hole < elements.count {                 // it wasn't the last one: fill the hole
                elements[hole] = last
                positions[last] = hole
            }
            return true
        }

        public func randomElement<G: RandomNumberGenerator>(using generator: inout G) -> Element? {
            elements.randomElement(using: &generator)  // O(1): arrays have random access
        }

        public func randomElement() -> Element? {
            var generator = SystemRandomNumberGenerator()
            return randomElement(using: &generator)
        }
    }
}
