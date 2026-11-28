// Kata: A typed in-app event bus (D08 · Event-driven architecture)
import Synchronization

public enum InAppEventBus {
    /// A fact that happened, named in the past tense: `OrderPlaced`, `SignedOut`
    public protocol Event: Sendable {}

    /// What one `publish` did: how many handlers were called, and how many of those threw
    public struct Delivery: Equatable, Sendable {
        public let delivered: Int
        public let failures: Int

        public init(delivered: Int, failures: Int) {
            self.delivered = delivered
            self.failures = failures
        }
    }

    /// Keeps a subscription alive. Call `cancel()`, or let the last reference go, to stop receiving
    /// events, as with Combine's `AnyCancellable`. This part is written for you: give it the closure that
    /// removes the subscriber, and it runs that closure once, on the first cancel or when it's released.
    public final class Subscription: Sendable {
        private let onCancel: Mutex<(@Sendable () -> Void)?>

        init(onCancel: @escaping @Sendable () -> Void) {
            self.onCancel = Mutex(onCancel)
        }

        public func cancel() {
            let action = onCancel.withLock { action in
                let taken = action
                action = nil
                return taken
            }
            action?()
        }

        deinit {
            cancel()
        }
    }

    /// Routes each event to the handlers subscribed to its type, synchronously, in the order they
    /// subscribed. Safe to use from any thread or task, and from inside a handler.
    public final class Bus: Sendable {
        public init() {}

        /// Calls `handler` with every `E` published until the returned subscription is cancelled or released
        public func subscribe<E: Event>(to type: E.Type, _ handler: @escaping @Sendable (E) throws -> Void) -> Subscription {
            // Write your solution here, then run:
            // swift test --filter InAppEventBusTests
            Subscription(onCancel: {})
        }

        /// Calls every current subscriber to `E`, in subscription order, before returning. A handler that
        /// throws doesn't stop the others; it's counted in `failures`.
        @discardableResult
        public func publish<E: Event>(_ event: E) -> Delivery {
            Delivery(delivered: 0, failures: 0)
        }

        /// How many live subscriptions there are to `E`
        public func subscriberCount<E: Event>(for type: E.Type) -> Int {
            0
        }
    }
}
