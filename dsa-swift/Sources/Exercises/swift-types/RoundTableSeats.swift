// Problem: Seats around a table (M09 · Identity with ===)

public enum RoundTableSeats {
    /// One seat. Following `next` leads either round a table, back to the starting seat,
    /// or along a row that ends with nil. Different seats may have guests with the same name.
    public final class Seat {
        public let guest: String
        public var next: Seat?

        public init(guest: String) {
            self.guest = guest
        }
    }

    /// The guests from `start` onwards, following `next`, with each seat listed once.
    public static func guests(from start: Seat) -> [String] {
        // Write your solution here, then run:
        // swift test --filter RoundTableSeatsTests
        return []
    }

    /// How many seats `guests(from:)` visits.
    public static func seatCount(from start: Seat) -> Int {
        return 0
    }

    /// True when following `next` from `start` arrives back at `start` itself.
    public static func isRoundTable(_ start: Seat) -> Bool {
        return false
    }

    /// How many different seat objects appear in `visits`.
    public static func distinctSeats(in visits: [Seat]) -> Int {
        return 0
    }
}
