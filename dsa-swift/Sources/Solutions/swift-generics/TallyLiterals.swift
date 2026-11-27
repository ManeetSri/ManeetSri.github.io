// Reference solution: A tally built from literals. Both literal initialisers hand their elements to add,
// so every rule lives in one place. A dictionary holds the counts and an array remembers the order
// elements first arrived. add and count(of:) are O(1); mostCommon and merged are O(d) for d distinct elements.

public enum TallyLiterals {
    public struct Tally<Element: Hashable>: ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
        private var counts: [Element: Int] = [:]
        public private(set) var elements: [Element] = []

        public init() {}

        public init(arrayLiteral elements: Element...) {
            for element in elements {
                add(element)
            }
        }

        public init(dictionaryLiteral pairs: (Element, Int)...) {
            for (element, times) in pairs {
                add(element, times: times)
            }
        }

        public mutating func add(_ element: Element, times: Int = 1) {
            guard times > 0 else {
                return
            }
            if counts[element] == nil {
                elements.append(element)
            }
            counts[element, default: 0] += times
        }

        public func count(of element: Element) -> Int {
            counts[element] ?? 0
        }

        public var total: Int {
            counts.values.reduce(0, +)
        }

        public var distinctCount: Int {
            elements.count
        }

        // Walking in arrival order and replacing only on a strictly higher count keeps the first on a tie
        public var mostCommon: Element? {
            var best: Element?
            var bestCount = 0
            for element in elements where count(of: element) > bestCount {
                best = element
                bestCount = count(of: element)
            }
            return best
        }

        public func merged(with other: Tally) -> Tally {
            var result = self
            for element in other.elements {
                result.add(element, times: other.count(of: element))
            }
            return result
        }
    }
}
