// Reference solution: A typing indicator. The sender keeps two timestamps (last signal, last keystroke) and
// a flag for whether the others think we're typing. The roster keeps one deadline per user and filters by
// it on every read, so expiry needs no timer of its own.
import DesignKit

public enum RealtimeTypingIndicator {
    public enum Signal: Equatable, Sendable {
        case typing
        case stopped
    }

    public struct Sender: Sendable {
        private let refresh: Duration
        private let idle: Duration
        private var lastSignalAt: Duration?
        private var lastKeystrokeAt: Duration = .zero
        private var announced = false

        public init(refresh: Duration = .seconds(3), idle: Duration = .seconds(5)) {
            self.refresh = refresh
            self.idle = idle
        }

        public mutating func textChanged(_ text: String, at now: Duration) -> Signal? {
            guard !text.isEmpty else {
                // Deleting everything is a clear "not typing any more"
                return stop()
            }
            lastKeystrokeAt = now
            if announced, let last = lastSignalAt, now - last < refresh {
                return nil
            }
            announced = true
            lastSignalAt = now
            return .typing
        }

        public mutating func messageSent() {
            // The message itself tells the others to clear the indicator: no extra signal needed
            announced = false
            lastSignalAt = nil
        }

        public mutating func tick(at now: Duration) -> Signal? {
            guard announced, now - lastKeystrokeAt >= idle else { return nil }
            return stop()
        }

        private mutating func stop() -> Signal? {
            guard announced else { return nil }
            announced = false
            lastSignalAt = nil
            return .stopped
        }
    }

    public struct Roster: Sendable {
        private let me: String
        private let expiry: Duration
        private var typingUntil: [String: Duration] = [:]

        public init(me: String, expiry: Duration = .seconds(8)) {
            self.me = me
            self.expiry = expiry
        }

        public mutating func received(_ signal: Signal, from user: String, at now: Duration) {
            guard user != me else { return }
            switch signal {
            case .typing:
                typingUntil[user] = now + expiry
            case .stopped:
                typingUntil[user] = nil
            }
        }

        public mutating func messageArrived(from user: String) {
            typingUntil[user] = nil
        }

        public func typing(at now: Duration) -> [String] {
            typingUntil.filter { now < $0.value }.keys.sorted()
        }

        public func summary(at now: Duration) -> String? {
            let users = typing(at: now)
            switch users.count {
            case 0: return nil
            case 1: return "\(users[0]) is typing…"
            case 2: return "\(users[0]) and \(users[1]) are typing…"
            default: return "Several people are typing…"
            }
        }
    }
}
