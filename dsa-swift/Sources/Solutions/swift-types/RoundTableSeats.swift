// Reference solution: Seats around a table. Walking stops when it reaches nil or arrives back at the very
// same seat it started from (`===`), never by comparing names, which can repeat. Each walk is O(n);
// distinctSeats is O(n) with a set of ObjectIdentifiers.

public enum RoundTableSeats {
    public final class Seat {
        public let guest: String
        public var next: Seat?

        public init(guest: String) {
            self.guest = guest
        }
    }

    public static func guests(from start: Seat) -> [String] {
        var names = [start.guest]
        var current = start.next
        while let seat = current, seat !== start {
            names.append(seat.guest)
            current = seat.next
        }
        return names
    }

    public static func seatCount(from start: Seat) -> Int {
        guests(from: start).count
    }

    public static func isRoundTable(_ start: Seat) -> Bool {
        var current = start.next
        while let seat = current {
            if seat === start {
                return true
            }
            current = seat.next
        }
        return false
    }

    public static func distinctSeats(in visits: [Seat]) -> Int {
        var seen = Set<ObjectIdentifier>()
        for seat in visits {
            seen.insert(ObjectIdentifier(seat))
        }
        return seen.count
    }
}
