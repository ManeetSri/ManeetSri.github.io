import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TickerBroadcastTests {
    typealias Channel = TickerBroadcast.Channel<Int>

    private final class Spy {
        var values: [Int] = []
    }

    @Test("Every live subscriber gets every value, in the order they subscribed")
    func deliversInOrder() {
        let channel = Channel()
        var log: [String] = []
        let first = channel.subscribe { log.append("first \($0)") }
        let second = channel.subscribe { log.append("second \($0)") }
        channel.send(1)
        channel.send(2)
        #expect(log == ["first 1", "second 1", "first 2", "second 2"])
        #expect(channel.subscriberCount == 2)
        withExtendedLifetime((first, second)) {}
    }

    @Test("A subscriber only hears values sent after it subscribed")
    func noReplay() {
        let channel = Channel()
        channel.send(1)
        var received: [Int] = []
        let subscription = channel.subscribe { received.append($0) }
        channel.send(2)
        #expect(received == [2])
        withExtendedLifetime(subscription) {}
    }

    @Test("Cancelling stops delivery at once, and cancelling twice is harmless")
    func cancelStopsDelivery() {
        let channel = Channel()
        var kept: [Int] = []
        var cancelled: [Int] = []
        let keeper = channel.subscribe { kept.append($0) }
        let leaver = channel.subscribe { cancelled.append($0) }
        channel.send(1)
        leaver.cancel()
        leaver.cancel()
        channel.send(2)
        #expect(kept == [1, 2])
        #expect(cancelled == [1])
        #expect(channel.subscriberCount == 1)
        withExtendedLifetime(keeper) {}
    }

    @Test("Letting go of the subscription cancels it")
    func releaseCancels() {
        let channel = Channel()
        var received: [Int] = []
        var subscription: TickerBroadcast.Subscription? = channel.subscribe { received.append($0) }
        channel.send(1)
        #expect(subscription != nil)
        subscription = nil
        channel.send(2)
        #expect(received == [1])
        #expect(channel.subscriberCount == 0)
    }

    @Test("Cancelling releases the handler and everything it captured")
    func cancelReleasesHandler() {
        let channel = Channel()
        weak var weakSpy: Spy?
        var subscription: TickerBroadcast.Subscription?
        do {
            let spy = Spy()
            weakSpy = spy
            subscription = channel.subscribe { spy.values.append($0) }
            channel.send(7)
            #expect(spy.values == [7])
        }
        #expect(weakSpy != nil, "the channel keeps a live handler")
        subscription?.cancel()
        #expect(weakSpy == nil, "a cancelled handler is released")
    }

    @Test("Subscriptions don't keep the channel alive, and outliving it is harmless")
    func outlivesChannel() {
        var channel: Channel? = Channel()
        weak var weakChannel = channel
        var received: [Int] = []
        let subscription = channel?.subscribe { received.append($0) }
        channel?.send(1)
        channel = nil
        #expect(received == [1])
        #expect(weakChannel == nil)
        subscription?.cancel()
    }

    @Test("A handler that cancels another mid-send stops it from hearing that same value")
    func cancelDuringSend() {
        let channel = Channel()
        var log: [String] = []
        var second: TickerBroadcast.Subscription?
        let first = channel.subscribe { value in
            log.append("first \(value)")
            second?.cancel()
        }
        second = channel.subscribe { log.append("second \($0)") }
        channel.send(1)
        channel.send(2)
        #expect(log == ["first 1", "first 2"])
        #expect(channel.subscriberCount == 1)
        withExtendedLifetime(first) {}
    }

    @Test("A subscriber added mid-send starts with the next value")
    func subscribeDuringSend() {
        let channel = Channel()
        var log: [String] = []
        var late: [TickerBroadcast.Subscription] = []
        let first = channel.subscribe { value in
            log.append("first \(value)")
            if late.isEmpty {
                late.append(channel.subscribe { log.append("late \($0)") })
            }
        }
        channel.send(1)
        channel.send(2)
        #expect(log == ["first 1", "first 2", "late 2"])
        #expect(channel.subscriberCount == 2)
        withExtendedLifetime((first, late)) {}
    }
}
