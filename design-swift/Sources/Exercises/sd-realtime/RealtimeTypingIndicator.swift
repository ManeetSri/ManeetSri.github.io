// Kata: A typing indicator (D35 · Presence and typing indicators)
import DesignKit

public enum RealtimeTypingIndicator {
    /// What the app sends about the local user, and receives about everyone else
    public enum Signal: Equatable, Sendable {
        case typing
        case stopped
    }

    /// The sending side: turns a stream of keystrokes into a few signals. Times are offsets from any fixed
    /// start: the app passes `clock.now - start`, tests pass durations.
    public struct Sender: Sendable {
        private let refresh: Duration
        private let idle: Duration

        /// - Parameters:
        ///   - refresh: while typing goes on, send `.typing` again at most this often, so it never expires
        ///   - idle: send `.stopped` once there's been no keystroke for this long
        public init(refresh: Duration = .seconds(3), idle: Duration = .seconds(5)) {
            self.refresh = refresh
            self.idle = idle
        }

        /// The text field changed. Returns the signal to send now, if any.
        public mutating func textChanged(_ text: String, at now: Duration) -> Signal? {
            // Write your solution here, then run:
            // swift test --filter RealtimeTypingIndicatorTests
            nil
        }

        /// The user sent the message. The message itself clears the indicator for everyone else.
        public mutating func messageSent() {
        }

        /// Called on a timer. Returns `.stopped` once the user has gone quiet.
        public mutating func tick(at now: Duration) -> Signal? {
            nil
        }
    }

    /// The receiving side: who is typing in one conversation right now
    public struct Roster: Sendable {
        private let me: String
        private let expiry: Duration

        /// - Parameters:
        ///   - me: the local user, whose own signals come back from the server and must be ignored
        ///   - expiry: how long one `.typing` signal counts for, if nothing follows it
        public init(me: String, expiry: Duration = .seconds(8)) {
            self.me = me
            self.expiry = expiry
        }

        public mutating func received(_ signal: Signal, from user: String, at now: Duration) {
        }

        /// A chat message from `user` arrived
        public mutating func messageArrived(from user: String) {
        }

        /// Everyone typing at `now`, sorted by name
        public func typing(at now: Duration) -> [String] {
            []
        }

        /// "Ana is typing…", "Ana and Ben are typing…", "Several people are typing…", or nil for nobody
        public func summary(at now: Duration) -> String? {
            nil
        }
    }
}
