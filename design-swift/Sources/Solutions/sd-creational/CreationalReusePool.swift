// Reference solution: Reuse pool. Each identifier has a factory and a stack of idle elements. Dequeue
// pops the most recently returned element (it's the "warmest") and prepares it, or makes a new one;
// enqueue pushes, unless the element is already waiting, the identifier is unknown or the stack is at
// its limit. Every operation is O(1) except the duplicate check, which is O(idle) and idle is small.
import Foundation

public enum CreationalReusePool {
    public protocol Reusable: AnyObject {
        func prepareForReuse()
    }

    public enum PoolError: Error, Equatable, Sendable {
        case unregistered(String)
    }

    public final class Pool<Element: Reusable> {
        public private(set) var created = 0

        private let maxIdle: Int
        private var factories: [String: () -> Element] = [:]
        private var idle: [String: [Element]] = [:]

        public init(maxIdlePerIdentifier: Int = 8) {
            maxIdle = max(0, maxIdlePerIdentifier)
        }

        public func register(_ identifier: String, make: @escaping () -> Element) {
            factories[identifier] = make
        }

        public func dequeue(_ identifier: String) throws(PoolError) -> Element {
            guard let make = factories[identifier] else { throw .unregistered(identifier) }
            if let recycled = idle[identifier]?.popLast() {
                recycled.prepareForReuse()
                return recycled
            }
            created += 1
            return make()
        }

        public func enqueue(_ element: Element, for identifier: String) {
            guard factories[identifier] != nil else { return }
            var waiting = idle[identifier, default: []]
            guard waiting.count < maxIdle, !waiting.contains(where: { $0 === element }) else { return }
            waiting.append(element)
            idle[identifier] = waiting
        }

        public func idleCount(for identifier: String) -> Int {
            idle[identifier]?.count ?? 0
        }

        public func drain() {
            idle.removeAll()
        }
    }
}
