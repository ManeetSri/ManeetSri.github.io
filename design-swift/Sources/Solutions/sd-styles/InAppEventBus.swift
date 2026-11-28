// Reference solution: A typed in-app event bus. Handlers are kept per event type, keyed by the type's
// ObjectIdentifier, in subscription order. The lock guards only the bookkeeping: publish copies the
// handler list, releases the lock and then calls each handler, so a handler can publish, subscribe or
// cancel without deadlocking. Before each call it checks the subscriber is still live, so a cancel made
// by an earlier handler takes effect at once; a subscriber added mid-delivery waits for the next event.
import Synchronization

public enum InAppEventBus {
    public protocol Event: Sendable {}

    public struct Delivery: Equatable, Sendable {
        public let delivered: Int
        public let failures: Int

        public init(delivered: Int, failures: Int) {
            self.delivered = delivered
            self.failures = failures
        }
    }

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

    public final class Bus: Sendable {
        private struct Subscriber: Sendable {
            let id: UInt64
            let handle: @Sendable (any Event) throws -> Void
        }

        private struct State {
            var nextID: UInt64 = 0
            var subscribers: [ObjectIdentifier: [Subscriber]] = [:]
            var live: Set<UInt64> = []
        }

        private let state = Mutex(State())

        public init() {}

        public func subscribe<E: Event>(to type: E.Type, _ handler: @escaping @Sendable (E) throws -> Void) -> Subscription {
            let key = ObjectIdentifier(type)
            let id = state.withLock { state in
                state.nextID += 1
                let subscriber = Subscriber(id: state.nextID) { event in
                    if let event = event as? E { try handler(event) }
                }
                state.subscribers[key, default: []].append(subscriber)
                state.live.insert(subscriber.id)
                return subscriber.id
            }
            // Weak, so a subscription that outlives its bus doesn't keep the bus alive
            return Subscription { [weak self] in
                self?.remove(id, from: key)
            }
        }

        @discardableResult
        public func publish<E: Event>(_ event: E) -> Delivery {
            let key = ObjectIdentifier(E.self)
            let snapshot = state.withLock { $0.subscribers[key] ?? [] }
            var delivered = 0
            var failures = 0
            for subscriber in snapshot {
                guard state.withLock({ $0.live.contains(subscriber.id) }) else { continue }
                delivered += 1
                do {
                    try subscriber.handle(event)
                } catch {
                    failures += 1
                }
            }
            return Delivery(delivered: delivered, failures: failures)
        }

        public func subscriberCount<E: Event>(for type: E.Type) -> Int {
            state.withLock { $0.subscribers[ObjectIdentifier(type)]?.count ?? 0 }
        }

        private func remove(_ id: UInt64, from key: ObjectIdentifier) {
            state.withLock { state in
                state.live.remove(id)
                state.subscribers[key]?.removeAll { $0.id == id }
                if state.subscribers[key]?.isEmpty == true {
                    state.subscribers[key] = nil
                }
            }
        }
    }
}
