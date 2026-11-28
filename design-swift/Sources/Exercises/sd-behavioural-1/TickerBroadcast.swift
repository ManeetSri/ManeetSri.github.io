// Kata: Observers that cancel themselves (D12 · Observer and NotificationCenter)
import Foundation

public enum TickerBroadcast {
    /// A subject: every value sent reaches every live subscriber
    public final class Channel<Value> {
        public init() {}

        /// How many subscriptions are live
        public var subscriberCount: Int {
            0
        }

        /// Calls `handler` with every value sent from now on, until the subscription is cancelled or released
        public func subscribe(_ handler: @escaping (Value) -> Void) -> Subscription {
            // Write your solution here, then run:
            // swift test --filter TickerBroadcastTests
            Subscription(onCancel: {})
        }

        /// Delivers `value` to every live subscriber, in the order they subscribed
        public func send(_ value: Value) {}
    }

    /// Keeps one subscription alive. Cancel it, or let go of it, and its handler is never called again.
    public final class Subscription {
        init(onCancel: @escaping () -> Void) {}

        /// Stops delivery at once. Calling it again does nothing.
        public func cancel() {}
    }
}
