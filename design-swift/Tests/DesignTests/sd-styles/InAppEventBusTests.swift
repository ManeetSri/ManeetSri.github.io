import Synchronization
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct InAppEventBusTests {
    struct OrderPlaced: InAppEventBus.Event { let id: String }
    struct SignedOut: InAppEventBus.Event {}
    struct Outer: InAppEventBus.Event {}
    struct Inner: InAppEventBus.Event {}
    struct HandlerFailed: Error {}

    /// What the handlers did, in order, from whichever thread they ran on
    final class Log: Sendable {
        private let lines = Mutex<[String]>([])
        func add(_ line: String) { lines.withLock { $0.append(line) } }
        var all: [String] { lines.withLock { $0 } }
    }

    /// Somewhere a handler can find a subscription that was made after it
    final class Slot: Sendable {
        private let value = Mutex<InAppEventBus.Subscription?>(nil)
        func put(_ subscription: InAppEventBus.Subscription) { value.withLock { $0 = subscription } }
        var isEmpty: Bool { value.withLock { $0 == nil } }
        func cancel() { value.withLock { $0 }?.cancel() }
    }

    @Test("Each event reaches only the subscribers to its type")
    func routesByType() {
        let bus = InAppEventBus.Bus()
        let log = Log()
        let subscriptions = [
            bus.subscribe(to: OrderPlaced.self) { log.add("order \($0.id)") },
            bus.subscribe(to: SignedOut.self) { _ in log.add("signed out") },
        ]
        withExtendedLifetime(subscriptions) {
            #expect(bus.publish(OrderPlaced(id: "A12")) == InAppEventBus.Delivery(delivered: 1, failures: 0))
            #expect(log.all == ["order A12"])
            bus.publish(SignedOut())
            #expect(log.all == ["order A12", "signed out"])
            #expect(bus.publish(Outer()) == InAppEventBus.Delivery(delivered: 0, failures: 0))
        }
    }

    @Test("Subscribers are called in the order they subscribed, before publish returns")
    func subscriptionOrder() {
        let bus = InAppEventBus.Bus()
        let log = Log()
        let subscriptions = ["analytics", "badge", "receipts"].map { name in
            bus.subscribe(to: OrderPlaced.self) { _ in log.add(name) }
        }
        withExtendedLifetime(subscriptions) {
            bus.publish(OrderPlaced(id: "A12"))
            #expect(log.all == ["analytics", "badge", "receipts"])
            #expect(bus.subscriberCount(for: OrderPlaced.self) == 3)
        }
    }

    @Test("Publishing through `any Event` still finds the concrete type's subscribers")
    func existentialEvents() {
        let bus = InAppEventBus.Bus()
        let log = Log()
        let subscription = bus.subscribe(to: OrderPlaced.self) { log.add("order \($0.id)") }
        withExtendedLifetime(subscription) {
            let events: [any InAppEventBus.Event] = [OrderPlaced(id: "A12"), SignedOut(), OrderPlaced(id: "A13")]
            for event in events {
                bus.publish(event)
            }
            #expect(log.all == ["order A12", "order A13"])
        }
    }

    @Test("Cancelling stops delivery, and cancelling twice is harmless")
    func cancel() {
        let bus = InAppEventBus.Bus()
        let log = Log()
        let subscription = bus.subscribe(to: OrderPlaced.self) { log.add("order \($0.id)") }
        bus.publish(OrderPlaced(id: "A12"))
        subscription.cancel()
        subscription.cancel()
        bus.publish(OrderPlaced(id: "A13"))
        #expect(log.all == ["order A12"])
        #expect(bus.subscriberCount(for: OrderPlaced.self) == 0)
    }

    @Test("Letting go of the subscription unsubscribes, like AnyCancellable")
    func releaseUnsubscribes() {
        let bus = InAppEventBus.Bus()
        let log = Log()
        do {
            let subscription = bus.subscribe(to: OrderPlaced.self) { log.add("order \($0.id)") }
            withExtendedLifetime(subscription) {
                #expect(bus.subscriberCount(for: OrderPlaced.self) == 1)
                bus.publish(OrderPlaced(id: "A12"))
            }
        }
        #expect(bus.subscriberCount(for: OrderPlaced.self) == 0)
        bus.publish(OrderPlaced(id: "A13"))
        #expect(log.all == ["order A12"])
    }

    @Test("A handler that throws doesn't stop the others, and is counted")
    func failingHandler() {
        let bus = InAppEventBus.Bus()
        let log = Log()
        let subscriptions = [
            bus.subscribe(to: OrderPlaced.self) { _ in log.add("analytics") },
            bus.subscribe(to: OrderPlaced.self) { _ in throw HandlerFailed() },
            bus.subscribe(to: OrderPlaced.self) { _ in log.add("receipts") },
        ]
        withExtendedLifetime(subscriptions) {
            #expect(bus.publish(OrderPlaced(id: "A12")) == InAppEventBus.Delivery(delivered: 3, failures: 1))
            #expect(log.all == ["analytics", "receipts"])
        }
    }

    @Test("A subscriber cancelled by an earlier handler isn't called")
    func cancelDuringDelivery() {
        let bus = InAppEventBus.Bus()
        let log = Log()
        let later = Slot()
        let first = bus.subscribe(to: OrderPlaced.self) { _ in
            log.add("first")
            later.cancel()
        }
        let second = bus.subscribe(to: OrderPlaced.self) { _ in log.add("second") }
        later.put(bus.subscribe(to: OrderPlaced.self) { _ in log.add("third") })
        withExtendedLifetime([first, second]) {
            #expect(bus.publish(OrderPlaced(id: "A12")) == InAppEventBus.Delivery(delivered: 2, failures: 0))
            #expect(log.all == ["first", "second"])
            #expect(bus.subscriberCount(for: OrderPlaced.self) == 2)
        }
    }

    @Test("A subscriber added during a delivery hears the next event, not this one")
    func subscribeDuringDelivery() {
        let bus = InAppEventBus.Bus()
        let log = Log()
        let added = Slot()
        let subscription = bus.subscribe(to: OrderPlaced.self) { event in
            log.add("first \(event.id)")
            if added.isEmpty {
                added.put(bus.subscribe(to: OrderPlaced.self) { log.add("added \($0.id)") })
            }
        }
        withExtendedLifetime(subscription) {
            bus.publish(OrderPlaced(id: "A12"))
            bus.publish(OrderPlaced(id: "A13"))
            #expect(log.all == ["first A12", "first A13", "added A13"])
        }
    }

    @Test("A handler can publish: the inner event is delivered before the outer one carries on")
    func nestedPublish() {
        let bus = InAppEventBus.Bus()
        let log = Log()
        let subscriptions = [
            bus.subscribe(to: Outer.self) { _ in
                log.add("outer 1")
                bus.publish(Inner())
            },
            bus.subscribe(to: Outer.self) { _ in log.add("outer 2") },
            bus.subscribe(to: Inner.self) { _ in log.add("inner") },
        ]
        withExtendedLifetime(subscriptions) {
            bus.publish(Outer())
            #expect(log.all == ["outer 1", "inner", "outer 2"])
        }
    }

    @Test("Subscribing from many tasks at once loses nobody")
    func concurrentSubscribers() async {
        let bus = InAppEventBus.Bus()
        let log = Log()
        let subscriptions = await withTaskGroup(of: InAppEventBus.Subscription.self) { group in
            for index in 0..<100 {
                group.addTask {
                    bus.subscribe(to: OrderPlaced.self) { _ in log.add("\(index)") }
                }
            }
            var all: [InAppEventBus.Subscription] = []
            for await subscription in group {
                all.append(subscription)
            }
            return all
        }
        withExtendedLifetime(subscriptions) {
            #expect(bus.subscriberCount(for: OrderPlaced.self) == 100)
            #expect(bus.publish(OrderPlaced(id: "A12")) == InAppEventBus.Delivery(delivered: 100, failures: 0))
            #expect(Set(log.all).count == 100)
        }
    }
}
