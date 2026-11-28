// Reference solution: An ordering buffer. Messages ahead of the next expected number wait in a dictionary
// keyed by sequence number; delivering means draining the run that starts at the next number. A gap gets a
// grace period before the resend request, and a buffer that overflows gives up and asks for a snapshot.
import DesignKit

public enum RealtimeSequenceBuffer {
    public struct Message: Equatable, Sendable {
        public let seq: Int
        public let body: String

        public init(seq: Int, body: String) {
            self.seq = seq
            self.body = body
        }
    }

    public enum Action: Equatable, Sendable {
        case deliver(Message)
        case resend(ClosedRange<Int>)
        case resync
    }

    public struct Buffer: Sendable {
        public private(set) var lastDelivered: Int
        public private(set) var duplicates = 0
        public var isResyncing: Bool { resyncing }

        private let gapTimeout: Duration
        private let capacity: Int
        private var buffered: [Int: Message] = [:]
        private var gapOpenedAt: Duration?
        private var lastAskedAt: Duration?
        private var resyncing = false

        public init(after lastSeen: Int = 0, gapTimeout: Duration = .seconds(2), capacity: Int = 100) {
            lastDelivered = lastSeen
            self.gapTimeout = gapTimeout
            self.capacity = capacity
        }

        public mutating func receive(_ message: Message, at now: Duration) -> [Action] {
            guard message.seq > lastDelivered, buffered[message.seq] == nil else {
                duplicates += 1
                return []
            }
            buffered[message.seq] = message
            if resyncing {
                trimToCapacity()
                return []
            }
            if message.seq == lastDelivered + 1 {
                return drain(at: now)
            }
            if buffered.count > capacity {
                // Too far behind to fill in message by message: the snapshot will cover the oldest
                resyncing = true
                gapOpenedAt = nil
                lastAskedAt = nil
                trimToCapacity()
                return [.resync]
            }
            if gapOpenedAt == nil { gapOpenedAt = now }
            return []
        }

        public mutating func tick(at now: Duration) -> [Action] {
            guard !resyncing, let opened = gapOpenedAt else { return [] }
            guard now - (lastAskedAt ?? opened) >= gapTimeout else { return [] }
            lastAskedAt = now
            return missingRanges().map(Action.resend)
        }

        public mutating func resume(after snapshot: Int, at now: Duration) -> [Action] {
            lastDelivered = snapshot
            buffered = buffered.filter { $0.key > snapshot }
            resyncing = false
            gapOpenedAt = nil
            lastAskedAt = nil
            return drain(at: now)
        }

        /// Delivers the run that starts at the next expected number; whatever's left is a gap
        private mutating func drain(at now: Duration) -> [Action] {
            var actions: [Action] = []
            while let next = buffered.removeValue(forKey: lastDelivered + 1) {
                actions.append(.deliver(next))
                lastDelivered += 1
            }
            if buffered.isEmpty {
                gapOpenedAt = nil
                lastAskedAt = nil
            } else if gapOpenedAt == nil {
                gapOpenedAt = now
            }
            return actions
        }

        private func missingRanges() -> [ClosedRange<Int>] {
            var ranges: [ClosedRange<Int>] = []
            var start: Int?
            for seq in (lastDelivered + 1)...(buffered.keys.max() ?? lastDelivered + 1) {
                if buffered[seq] == nil {
                    if start == nil { start = seq }
                } else if let first = start {
                    ranges.append(first...(seq - 1))
                    start = nil
                }
            }
            return ranges
        }

        private mutating func trimToCapacity() {
            while buffered.count > capacity, let lowest = buffered.keys.min() {
                buffered[lowest] = nil
            }
        }
    }
}
