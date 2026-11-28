// Kata: A seat hold you can only settle once (D06 · ~Copyable types and ownership)
import Synchronization

public enum ConsumableSeatHold {
    public enum HoldError: Error, Equatable, Sendable {
        /// Not enough seats are available to hold
        case soldOut
        /// The hold's time ran out before it was confirmed
        case expired
    }

    public struct Receipt: Equatable, Sendable {
        public let holdID: Int
        public let seats: Int

        public init(holdID: Int, seats: Int) {
            self.holdID = holdID
            self.seats = seats
        }
    }

    /// The box office's books for one show. Every seat is available, held or sold. A hold's deinit
    /// returns seats synchronously, so the books sit behind a Mutex rather than inside an actor.
    public final class BoxOffice: Sendable {
        public init(seats: Int) {
            // Write your solution here, then run:
            // swift test --filter ConsumableSeatHoldTests
        }

        public var available: Int { 0 }
        public var held: Int { 0 }
        public var sold: Int { 0 }
        /// Seconds since the box office opened. Only `advance(by:)` moves it.
        public var now: Int { 0 }

        public func advance(by seconds: Int) {}

        /// Holds `count` seats for `seconds` from now. Hold ids count up from 1.
        public func hold(_ count: Int, for seconds: Int) throws(HoldError) -> Hold {
            Hold(id: 0, seats: count, expiresAt: 0, office: self)
        }
    }

    /// Seats held for one customer. It can't be copied, so it's settled at most once: confirmed,
    /// released, or dropped, in which case its seats go back by themselves.
    public struct Hold: ~Copyable {
        public let id: Int
        public let seats: Int
        /// The moment, on the box office's clock, when the hold stops being confirmable
        public let expiresAt: Int
        private let office: BoxOffice

        fileprivate init(id: Int, seats: Int, expiresAt: Int, office: BoxOffice) {
            self.id = id
            self.seats = seats
            self.expiresAt = expiresAt
            self.office = office
        }

        /// Sells the held seats. After `expiresAt` it throws `.expired`, and the seats go back.
        public consuming func confirm() throws(HoldError) -> Receipt {
            Receipt(holdID: 0, seats: 0)
        }

        /// Gives the seats back now
        public consuming func release() {}

        deinit {}
    }
}
