import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct QueuedLikesOutboxTests {
    private typealias Outbox = QueuedLikesOutbox
    private typealias Like = QueuedLikesOutbox.PendingLike

    /// Everything the shell asked the outside world to do, in order
    private enum Call: Equatable, Sendable {
        case load
        case send(String)
        case save([Like])
    }

    /// Closures that answer from fixed data and record every call: no network, no disk
    private func world(online: Bool = true, outbox: [Like], outcomes: [String: Outbox.Outcome] = [:], calls: Recorder<Call>) -> Outbox.Dependencies {
        Outbox.Dependencies(
            isOnline: { online },
            load: {
                await calls.record(.load)
                return outbox
            },
            send: { like in
                await calls.record(.send(like.postID))
                return outcomes[like.postID] ?? .sent
            },
            save: { likes in
                await calls.record(.save(likes))
            }
        )
    }

    // MARK: The core

    @Test("A batch keeps outbox order, skips likes that failed too often, and stops at the limit")
    func batch() {
        let outbox = [Like(postID: "a"), Like(postID: "b", failures: 3), Like(postID: "c", failures: 1), Like(postID: "d")]
        #expect(Outbox.batch(from: outbox, limit: 2, maxFailures: 3) == [Like(postID: "a"), Like(postID: "c", failures: 1)])
        #expect(Outbox.batch(from: outbox, limit: 10, maxFailures: 3).map(\.postID) == ["a", "c", "d"])
        #expect(Outbox.batch(from: outbox, limit: 10, maxFailures: 1).map(\.postID) == ["a", "d"])
        #expect(Outbox.batch(from: outbox, limit: 0, maxFailures: 3).isEmpty)
        #expect(Outbox.batch(from: [], limit: 5, maxFailures: 3).isEmpty)
    }

    @Test("Applying outcomes drops sent and rejected likes, counts failures, and leaves untried likes alone")
    func applying() {
        let outbox = [Like(postID: "a"), Like(postID: "b", failures: 1), Like(postID: "c"), Like(postID: "d"), Like(postID: "e", failures: 2)]
        let after = Outbox.applying(["a": .sent, "b": .failed, "c": .rejected, "e": .failed], to: outbox)
        #expect(after == [Like(postID: "b", failures: 2), Like(postID: "d"), Like(postID: "e", failures: 3)])
        #expect(Outbox.applying([:], to: outbox) == outbox)
    }

    // MARK: The shell

    @Test("Online, a flush loads, sends the batch in order, saves once and counts what was sent")
    func flush() async {
        let calls = Recorder<Call>()
        let outbox = [Like(postID: "a"), Like(postID: "b", failures: 3), Like(postID: "c"), Like(postID: "d")]
        let sent = await Outbox.flush(world(outbox: outbox, outcomes: ["c": .failed], calls: calls), limit: 2)
        #expect(sent == 1)
        #expect(await calls.values == [
            .load,
            .send("a"),
            .send("c"),
            .save([Like(postID: "b", failures: 3), Like(postID: "c", failures: 1), Like(postID: "d")]),
        ])
    }

    @Test("Offline, a flush touches nothing; back online, the same outbox goes out")
    func offline() async {
        let calls = Recorder<Call>()
        let outbox = [Like(postID: "a"), Like(postID: "b")]
        #expect(await Outbox.flush(world(online: false, outbox: outbox, calls: calls)) == 0)
        #expect(await calls.values.isEmpty)

        #expect(await Outbox.flush(world(online: true, outbox: outbox, calls: calls)) == 2)
        #expect(await calls.values == [.load, .send("a"), .send("b"), .save([])])
    }

    @Test("With nothing worth sending, a flush loads but never saves")
    func nothingToSend() async {
        let calls = Recorder<Call>()
        let exhausted = [Like(postID: "a", failures: 3), Like(postID: "b", failures: 5)]
        let sent = await Outbox.flush(world(outbox: exhausted, calls: calls))
        #expect(sent == 0)
        #expect(await calls.values == [.load])
    }

    @Test("The default batch is five likes, and rejected likes don't count as sent")
    func defaults() async {
        let calls = Recorder<Call>()
        let outbox = (1...7).map { Like(postID: "p\($0)") }
        let sent = await Outbox.flush(world(outbox: outbox, outcomes: ["p2": .rejected], calls: calls))
        #expect(sent == 4)
        #expect(await calls.values == [
            .load, .send("p1"), .send("p2"), .send("p3"), .send("p4"), .send("p5"),
            .save([Like(postID: "p6"), Like(postID: "p7")]),
        ])
    }
}
