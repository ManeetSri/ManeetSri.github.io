// Kata: Reuse pool (D10 · Object pools and reuse, from cells to formatters)
import Foundation

public enum CreationalReusePool {
    /// Something a pool can hand out again, like a cell
    public protocol Reusable: AnyObject {
        /// Called just before a recycled element is handed out again, never on a new one
        func prepareForReuse()
    }

    public enum PoolError: Error, Equatable, Sendable {
        case unregistered(String)
    }

    /// The pool behind `dequeueReusableCell`: one queue of idle elements per reuse identifier.
    /// Like UIKit's, it isn't thread-safe: use it from one thread or actor.
    public final class Pool<Element: Reusable> {
        /// How many elements have been made so far, across every identifier
        public private(set) var created = 0

        public init(maxIdlePerIdentifier: Int = 8) {}

        /// How to make a new element for `identifier`; registering again replaces the factory
        public func register(_ identifier: String, make: @escaping () -> Element) {
            // Write your solution here, then run:
            // swift test --filter CreationalReusePoolTests
        }

        /// The most recently enqueued idle element, prepared for reuse, or a new one if none is waiting
        public func dequeue(_ identifier: String) throws(PoolError) -> Element {
            throw .unregistered(identifier)
        }

        /// Puts an element back to wait for reuse
        public func enqueue(_ element: Element, for identifier: String) {}

        /// How many elements are waiting for `identifier`
        public func idleCount(for identifier: String) -> Int {
            0
        }

        /// Lets go of every idle element, as on a memory warning
        public func drain() {}
    }
}
