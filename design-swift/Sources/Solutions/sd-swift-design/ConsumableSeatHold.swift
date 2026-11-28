// Reference solution: A seat hold. The hold is ~Copyable, so it can't be confirmed twice or used after
// release: consuming methods end its life. deinit is the one place held seats go back, so a hold that's
// released, dropped or found to have expired returns its seats exactly once. A successful confirm marks
// the hold settled first, so its deinit has nothing to do. (`discard self` would skip deinit, but Swift
// only allows it in types whose stored properties need no cleanup, and a hold keeps a reference to
// its box office.)
import Synchronization

public enum ConsumableSeatHold {
    public enum HoldError: Error, Equatable, Sendable {
        case soldOut
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

    public final class BoxOffice: Sendable {
        private struct Books {
            var available: Int
            var held = 0
            var sold = 0
            var now = 0
            var lastHoldID = 0
        }

        private let books: Mutex<Books>

        public init(seats: Int) {
            books = Mutex(Books(available: seats))
        }

        public var available: Int { books.withLock { $0.available } }
        public var held: Int { books.withLock { $0.held } }
        public var sold: Int { books.withLock { $0.sold } }
        public var now: Int { books.withLock { $0.now } }

        public func advance(by seconds: Int) {
            books.withLock { $0.now += seconds }
        }

        public func hold(_ count: Int, for seconds: Int) throws(HoldError) -> Hold {
            // Mutex.withLock is generic over its closure's error type, so a typed throw passes straight through
            let placed = try books.withLock { (books) throws(HoldError) -> (id: Int, expiresAt: Int) in
                guard count <= books.available else { throw .soldOut }
                books.available -= count
                books.held += count
                books.lastHoldID += 1
                return (books.lastHoldID, books.now + seconds)
            }
            return Hold(id: placed.id, seats: count, expiresAt: placed.expiresAt, office: self)
        }

        // Both return false, changing nothing, when the hold has expired
        fileprivate func sell(_ seats: Int, expiresAt: Int) -> Bool {
            books.withLock { books in
                guard books.now < expiresAt else { return false }
                books.held -= seats
                books.sold += seats
                return true
            }
        }

        fileprivate func release(_ seats: Int) {
            books.withLock { books in
                books.held -= seats
                books.available += seats
            }
        }
    }

    public struct Hold: ~Copyable {
        public let id: Int
        public let seats: Int
        public let expiresAt: Int
        private let office: BoxOffice
        private var settled = false

        fileprivate init(id: Int, seats: Int, expiresAt: Int, office: BoxOffice) {
            self.id = id
            self.seats = seats
            self.expiresAt = expiresAt
            self.office = office
        }

        public consuming func confirm() throws(HoldError) -> Receipt {
            guard office.sell(seats, expiresAt: expiresAt) else {
                // Not settled, so deinit returns the seats as this method ends
                throw .expired
            }
            settled = true
            return Receipt(holdID: id, seats: seats)
        }

        public consuming func release() {
            // Nothing to do: consuming ends the hold's life here, and deinit returns the seats
        }

        deinit {
            if !settled {
                office.release(seats)
            }
        }
    }
}
