// Reference solution: Compose a playback queue. Instead of a subclass for every combination (shuffling,
// repeating, skip-limited), the player holds three parts: an ordering (an open set, so a protocol), a
// repeat mode (a closed set, so an enum) and a skip allowance (a protocol with its own state). Any
// combination works, including parts written long after the player.
import DesignKit

public enum PrinciplesPlaybackQueue {
    public protocol Ordering: Sendable {
        func arrange(_ tracks: [String]) -> [String]
    }

    public struct InOrder: Ordering {
        public init() {}

        public func arrange(_ tracks: [String]) -> [String] {
            tracks
        }
    }

    public struct Shuffled: Ordering {
        public let seed: UInt64

        public init(seed: UInt64) {
            self.seed = seed
        }

        public func arrange(_ tracks: [String]) -> [String] {
            var generator = SeededGenerator(seed: seed)
            return tracks.shuffled(using: &generator)
        }
    }

    public enum RepeatMode: Sendable, Equatable {
        case off
        case all
        case one
    }

    public protocol SkipAllowance: Sendable {
        mutating func useSkip() -> Bool
    }

    public struct UnlimitedSkips: SkipAllowance {
        public init() {}

        public mutating func useSkip() -> Bool {
            true
        }
    }

    public struct LimitedSkips: SkipAllowance {
        private var remaining: Int

        public init(_ limit: Int) {
            remaining = max(0, limit)
        }

        public mutating func useSkip() -> Bool {
            guard remaining > 0 else { return false }
            remaining -= 1
            return true
        }
    }

    public struct Player {
        private let queue: [String]
        private let repeatMode: RepeatMode
        private var skips: any SkipAllowance
        private var position: Int?

        public init(tracks: [String], ordering: any Ordering = InOrder(), repeatMode: RepeatMode = .off, skips: any SkipAllowance = UnlimitedSkips()) {
            queue = ordering.arrange(tracks)
            self.repeatMode = repeatMode
            self.skips = skips
            position = queue.isEmpty ? nil : 0
        }

        public var current: String? {
            position.map { queue[$0] }
        }

        public mutating func trackDidFinish() {
            guard let position else { return }
            self.position = repeatMode == .one ? position : self.position(after: position)
        }

        public mutating func skip() -> Bool {
            guard let position, skips.useSkip() else { return false }
            self.position = self.position(after: position)
            return true
        }

        // The next position, wrapping round only for repeat all; nil when the queue has ended
        private func position(after position: Int) -> Int? {
            if position + 1 < queue.count { return position + 1 }
            return repeatMode == .all ? 0 : nil
        }
    }
}
