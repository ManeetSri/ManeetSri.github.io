// Reference solution: Observers that cancel themselves. The channel keeps handlers in a dictionary keyed by
// id plus an array for their order; a subscription holds only a closure that removes its id through a weak
// reference, so neither side keeps the other alive. `send` walks a snapshot of the ids and looks each one
// up again, so a handler cancelled mid-send is skipped and one added mid-send waits for the next value.
import Foundation

public enum TickerBroadcast {
    public final class Channel<Value> {
        private var handlers: [Int: (Value) -> Void] = [:]
        private var order: [Int] = []
        private var nextID = 0

        public init() {}

        public var subscriberCount: Int {
            handlers.count
        }

        public func subscribe(_ handler: @escaping (Value) -> Void) -> Subscription {
            let id = nextID
            nextID += 1
            handlers[id] = handler
            order.append(id)
            return Subscription { [weak self] in
                self?.remove(id)
            }
        }

        public func send(_ value: Value) {
            for id in order {
                handlers[id]?(value)
            }
        }

        private func remove(_ id: Int) {
            handlers[id] = nil
            order.removeAll { $0 == id }
        }
    }

    public final class Subscription {
        private var onCancel: (() -> Void)?

        init(onCancel: @escaping () -> Void) {
            self.onCancel = onCancel
        }

        public func cancel() {
            let action = onCancel
            onCancel = nil
            action?()
        }

        deinit {
            cancel()
        }
    }
}
