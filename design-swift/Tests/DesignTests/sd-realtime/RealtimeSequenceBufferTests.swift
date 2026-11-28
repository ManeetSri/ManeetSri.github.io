import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RealtimeSequenceBufferTests {
    private typealias Ordering = RealtimeSequenceBuffer

    private func message(_ seq: Int) -> Ordering.Message {
        Ordering.Message(seq: seq, body: "m\(seq)")
    }

    private func delivered(_ seqs: Int...) -> [Ordering.Action] {
        seqs.map { .deliver(message($0)) }
    }

    @Test("Messages that arrive in order are delivered at once")
    func inOrder() {
        var buffer = Ordering.Buffer()
        let first = buffer.receive(message(1), at: .zero)
        let second = buffer.receive(message(2), at: .zero)
        #expect(first == delivered(1))
        #expect(second == delivered(2))
        #expect(buffer.lastDelivered == 2)
    }

    @Test("A buffer that starts after a known number expects the one after it")
    func startsAfterLastSeen() {
        var buffer = Ordering.Buffer(after: 41)
        let old = buffer.receive(message(41), at: .zero)
        let next = buffer.receive(message(42), at: .zero)
        #expect(old == [])
        #expect(next == delivered(42))
        #expect(buffer.duplicates == 1)
    }

    @Test("Messages ahead of a gap wait, then come out in order once it fills")
    func waitsForGap() {
        var buffer = Ordering.Buffer()
        let early = [buffer.receive(message(3), at: .zero), buffer.receive(message(2), at: .zero)]
        let filled = buffer.receive(message(1), at: .seconds(1))
        #expect(early == [[], []])
        #expect(filled == delivered(1, 2, 3))
        #expect(buffer.lastDelivered == 3)
    }

    @Test("Duplicates are dropped and counted, whether already delivered or already waiting")
    func duplicates() {
        var buffer = Ordering.Buffer()
        _ = buffer.receive(message(1), at: .zero)
        _ = buffer.receive(message(3), at: .zero)
        let again = [
            buffer.receive(message(1), at: .zero),
            buffer.receive(message(3), at: .zero),
            buffer.receive(Ordering.Message(seq: 1, body: "replayed"), at: .zero),
        ]
        let fill = buffer.receive(message(2), at: .zero)
        #expect(again == [[], [], []])
        #expect(buffer.duplicates == 3)
        #expect(fill == delivered(2, 3))
    }

    @Test("A gap gets a grace period before the resend request, which names every missing range")
    func resendAfterGrace() {
        var buffer = Ordering.Buffer(gapTimeout: .seconds(2))
        _ = buffer.receive(message(1), at: .zero)
        _ = buffer.receive(message(3), at: .seconds(1))
        _ = buffer.receive(message(6), at: .seconds(1))
        let tooSoon = buffer.tick(at: .milliseconds(2999))
        let ask = buffer.tick(at: .seconds(3))
        #expect(tooSoon == [])
        #expect(ask == [.resend(2...2), .resend(4...5)])
    }

    @Test("While the gap stays open it asks again every timeout, and stops once it fills")
    func asksAgainUntilFilled() {
        var buffer = Ordering.Buffer(gapTimeout: .seconds(2))
        _ = buffer.receive(message(2), at: .zero)
        let first = buffer.tick(at: .seconds(2))
        let between = buffer.tick(at: .seconds(3))
        let second = buffer.tick(at: .seconds(4))
        let filled = buffer.receive(message(1), at: .seconds(5))
        let after = buffer.tick(at: .seconds(10))
        #expect(first == [.resend(1...1)])
        #expect(between == [])
        #expect(second == [.resend(1...1)])
        #expect(filled == delivered(1, 2))
        #expect(after == [])
    }

    @Test("A gap that partly fills keeps its timer; a new gap waits a full timeout")
    func gapTimers() {
        var buffer = Ordering.Buffer(gapTimeout: .seconds(2))
        _ = buffer.receive(message(2), at: .zero)
        _ = buffer.receive(message(4), at: .zero)
        let partly = buffer.receive(message(1), at: .seconds(1))
        let ask = buffer.tick(at: .seconds(2))
        let rest = buffer.receive(message(3), at: .seconds(2))
        _ = buffer.receive(message(6), at: .seconds(10))
        let tooSoon = buffer.tick(at: .seconds(11))
        let newAsk = buffer.tick(at: .seconds(12))
        #expect(partly == delivered(1, 2))
        #expect(ask == [.resend(3...3)])
        #expect(rest == delivered(3, 4))
        #expect(tooSoon == [])
        #expect(newAsk == [.resend(5...5)])
    }

    @Test("Overflowing the buffer asks once for a resync, and stops delivering and asking")
    func overflowResyncs() {
        var buffer = Ordering.Buffer(gapTimeout: .seconds(2), capacity: 3)
        let waiting = (3...5).map { buffer.receive(message($0), at: .zero) }
        let overflow = buffer.receive(message(6), at: .zero)
        let more = buffer.receive(message(7), at: .zero)
        let missing = buffer.receive(message(1), at: .zero)
        let ask = buffer.tick(at: .seconds(10))
        #expect(waiting == [[], [], []])
        #expect(overflow == [.resync])
        #expect(more == [])
        #expect(missing == [])
        #expect(ask == [])
        #expect(buffer.isResyncing)
        #expect(buffer.lastDelivered == 0)
    }

    @Test("Resuming after a snapshot drops what it covers and delivers what follows")
    func resumeAfterSnapshot() {
        var buffer = Ordering.Buffer(gapTimeout: .seconds(2), capacity: 3)
        (3...8).forEach { _ = buffer.receive(message($0), at: .zero) }
        // Only the three highest are kept while resyncing: 6, 7 and 8
        let resumed = buffer.resume(after: 5, at: .seconds(1))
        #expect(resumed == delivered(6, 7, 8))
        #expect(!buffer.isResyncing)
        #expect(buffer.lastDelivered == 8)
    }

    @Test("A snapshot that leaves a gap opens a new one, timed from the resume")
    func resumeIntoGap() {
        var buffer = Ordering.Buffer(gapTimeout: .seconds(2), capacity: 2)
        (4...7).forEach { _ = buffer.receive(message($0), at: .zero) }
        // Kept while resyncing: 6 and 7. The snapshot only reaches 4, so 5 is missing.
        let resumed = buffer.resume(after: 4, at: .seconds(10))
        let tooSoon = buffer.tick(at: .seconds(11))
        let ask = buffer.tick(at: .seconds(12))
        let filled = buffer.receive(message(5), at: .seconds(12))
        #expect(resumed == [])
        #expect(tooSoon == [])
        #expect(ask == [.resend(5...5)])
        #expect(filled == delivered(5, 6, 7))
    }
}
