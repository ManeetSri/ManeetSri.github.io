import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RealtimeTypingIndicatorTests {
    private typealias Typing = RealtimeTypingIndicator

    /// Types one character per `gap` and returns the signal sent after each keystroke, if any
    private func keystrokes(_ sender: inout Typing.Sender, _ count: Int, from start: Duration = .zero, every gap: Duration = .milliseconds(500)) -> [Typing.Signal?] {
        (1...count).map { index in
            sender.textChanged(String(repeating: "a", count: index), at: start + gap * (index - 1))
        }
    }

    @Test("The first keystroke sends typing at once; the next ones within the refresh interval send nothing")
    func leadingEdge() {
        var sender = Typing.Sender(refresh: .seconds(3), idle: .seconds(5))
        let signals = keystrokes(&sender, 6)
        #expect(signals == [.typing, nil, nil, nil, nil, nil])
    }

    @Test("Typing that goes on refreshes the signal once per interval, so it never expires mid-sentence")
    func refreshes() {
        var sender = Typing.Sender(refresh: .seconds(3), idle: .seconds(5))
        // Keystrokes at 0, 0.5 … 7.5 s: typing goes out at 0, 3 and 6 s
        let signals = keystrokes(&sender, 16)
        let sentAt = signals.indices.filter { signals[$0] == .typing }.map { $0 * 500 }
        #expect(sentAt == [0, 3000, 6000])
        #expect(signals.allSatisfy { $0 != .stopped })
    }

    @Test("Going quiet sends stopped once, after the idle time")
    func stopsWhenIdle() {
        var sender = Typing.Sender(refresh: .seconds(3), idle: .seconds(5))
        _ = sender.textChanged("Hi", at: .seconds(10))
        let early = sender.tick(at: .milliseconds(14_999))
        let due = sender.tick(at: .seconds(15))
        let again = sender.tick(at: .seconds(20))
        #expect(early == nil)
        #expect(due == .stopped)
        #expect(again == nil)
    }

    @Test("Clearing the field sends stopped, and typing again starts afresh")
    func clearing() {
        var sender = Typing.Sender(refresh: .seconds(3), idle: .seconds(5))
        let started = sender.textChanged("H", at: .zero)
        let cleared = sender.textChanged("", at: .seconds(1))
        let clearedAgain = sender.textChanged("", at: .seconds(1))
        let restarted = sender.textChanged("O", at: .milliseconds(1500))
        #expect(started == .typing)
        #expect(cleared == .stopped)
        #expect(clearedAgain == nil)
        #expect(restarted == .typing)
    }

    @Test("Sending the message needs no stopped signal; the next keystroke announces typing again")
    func messageSent() {
        var sender = Typing.Sender(refresh: .seconds(3), idle: .seconds(5))
        _ = sender.textChanged("Hello", at: .zero)
        sender.messageSent()
        let idle = sender.tick(at: .seconds(30))
        let next = sender.textChanged("A", at: .seconds(31))
        #expect(idle == nil)
        #expect(next == .typing)
    }

    @Test("Never typing means never stopping")
    func noStopWithoutStart() {
        var sender = Typing.Sender()
        let cleared = sender.textChanged("", at: .zero)
        let ticked = sender.tick(at: .seconds(60))
        #expect(cleared == nil)
        #expect(ticked == nil)
    }

    @Test("A typing signal counts until it expires, and each refresh extends it")
    func rosterExpiry() {
        var roster = Typing.Roster(me: "me", expiry: .seconds(8))
        roster.received(.typing, from: "Ana", at: .zero)
        #expect(roster.typing(at: .seconds(7)) == ["Ana"])
        roster.received(.typing, from: "Ana", at: .seconds(6))
        #expect(roster.typing(at: .seconds(13)) == ["Ana"])
        #expect(roster.typing(at: .seconds(14)) == [])
    }

    @Test("Stopped, or a message from that person, clears them at once")
    func rosterClears() {
        var roster = Typing.Roster(me: "me")
        roster.received(.typing, from: "Ana", at: .zero)
        roster.received(.typing, from: "Ben", at: .zero)
        #expect(roster.typing(at: .zero) == ["Ana", "Ben"])
        roster.received(.stopped, from: "Ana", at: .seconds(1))
        roster.messageArrived(from: "Ben")
        #expect(roster.typing(at: .seconds(1)) == [])
    }

    @Test("Your own signals, echoed back by the server, never show")
    func ignoresMe() {
        var roster = Typing.Roster(me: "me")
        roster.received(.typing, from: "me", at: .zero)
        roster.received(.typing, from: "Ana", at: .zero)
        #expect(roster.typing(at: .seconds(1)) == ["Ana"])
    }

    @Test("The summary names one or two people, then gives up counting")
    func summary() {
        var roster = Typing.Roster(me: "me", expiry: .seconds(8))
        #expect(roster.summary(at: .zero) == nil)
        roster.received(.typing, from: "Ben", at: .zero)
        #expect(roster.summary(at: .seconds(1)) == "Ben is typing…")
        roster.received(.typing, from: "Ana", at: .zero)
        #expect(roster.summary(at: .seconds(1)) == "Ana and Ben are typing…")
        roster.received(.typing, from: "Cal", at: .seconds(2))
        #expect(roster.summary(at: .seconds(3)) == "Several people are typing…")
        #expect(roster.summary(at: .seconds(9)) == "Cal is typing…")
    }
}
