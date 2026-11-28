// Kata: Compose a playback queue (D05 · Composition over inheritance)
import DesignKit

public enum PrinciplesPlaybackQueue {
    /// Decides the order that one pass through the tracks plays in. New kinds are expected: the tests add
    /// one of their own.
    public protocol Ordering: Sendable {
        func arrange(_ tracks: [String]) -> [String]
    }

    /// The tracks in the order they were given
    public struct InOrder: Ordering {
        public init() {}

        public func arrange(_ tracks: [String]) -> [String] {
            // Write your solution here, then run:
            // swift test --filter PrinciplesPlaybackQueueTests
            return []
        }
    }

    /// Every track once, shuffled with `SeededGenerator(seed:)`, so a seed always gives the same order
    public struct Shuffled: Ordering {
        public let seed: UInt64

        public init(seed: UInt64) {
            self.seed = seed
        }

        public func arrange(_ tracks: [String]) -> [String] {
            return []
        }
    }

    /// What happens when a track ends on its own. Apple's three modes: a closed set, so an enum.
    public enum RepeatMode: Sendable, Equatable {
        /// Play to the end of the queue, then stop
        case off
        /// After the last track, start the same order again
        case all
        /// Play the current track again
        case one
    }

    /// Decides whether the listener may skip right now
    public protocol SkipAllowance: Sendable {
        /// Asked once for every skip the listener tries. Returns whether this skip is allowed, and counts it
        /// if it is.
        mutating func useSkip() -> Bool
    }

    /// Skip as often as you like
    public struct UnlimitedSkips: SkipAllowance {
        public init() {}

        public mutating func useSkip() -> Bool {
            return false
        }
    }

    /// A fixed number of skips, as on a free tier
    public struct LimitedSkips: SkipAllowance {
        public init(_ limit: Int) {}

        public mutating func useSkip() -> Bool {
            return false
        }
    }

    /// Plays its tracks in the order its `Ordering` arranges them (once, when it's created), follows its
    /// repeat mode, and asks its `SkipAllowance` before every skip. It knows none of their concrete kinds.
    public struct Player {
        public init(tracks: [String], ordering: any Ordering = InOrder(), repeatMode: RepeatMode = .off, skips: any SkipAllowance = UnlimitedSkips()) {}

        /// The track playing now; `nil` once the queue has ended, or if it was empty
        public var current: String? {
            nil
        }

        /// The current track ended on its own: move on as the repeat mode says
        public mutating func trackDidFinish() {}

        /// The listener tapped skip. If there's a current track and the allowance agrees, move to the next
        /// track and return `true`. Repeat one doesn't apply to skips; repeat all still wraps round.
        public mutating func skip() -> Bool {
            return false
        }
    }
}
