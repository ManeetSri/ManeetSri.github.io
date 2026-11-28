import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RoundTableSeatsTests {
    typealias Seat = RoundTableSeats.Seat

    /// Seats the guests in order and returns them. When `round` is true the last seat points back to the first.
    private static func seats(_ guests: [String], round: Bool) -> [Seat] {
        let seats = guests.map { Seat(guest: $0) }
        for index in seats.indices.dropLast() {
            seats[index].next = seats[index + 1]
        }
        if round {
            seats.last?.next = seats.first
        }
        return seats
    }

    @Test("Walking a round table visits each seat once")
    func roundTable() {
        let table = Self.seats(["Asha", "Ravi", "Mina", "Kofi"], round: true)
        #expect(RoundTableSeats.guests(from: table[0]) == ["Asha", "Ravi", "Mina", "Kofi"])
        #expect(RoundTableSeats.guests(from: table[2]) == ["Mina", "Kofi", "Asha", "Ravi"])
        #expect(RoundTableSeats.seatCount(from: table[1]) == 4)
        #expect(RoundTableSeats.isRoundTable(table[3]))
    }

    @Test("Repeated names don't stop the walk early")
    func repeatedNames() {
        let table = Self.seats(["Sam", "Sam", "Ali", "Sam"], round: true)
        #expect(RoundTableSeats.seatCount(from: table[0]) == 4)
        #expect(RoundTableSeats.guests(from: table[1]) == ["Sam", "Ali", "Sam", "Sam"])
        #expect(RoundTableSeats.isRoundTable(table[0]))
    }

    @Test("A row of seats ends at nil")
    func row() {
        let row = Self.seats(["Asha", "Ravi", "Asha"], round: false)
        #expect(RoundTableSeats.guests(from: row[0]) == ["Asha", "Ravi", "Asha"])
        #expect(RoundTableSeats.seatCount(from: row[1]) == 2)
        #expect(!RoundTableSeats.isRoundTable(row[0]))
    }

    @Test("A single seat, alone or facing itself")
    func singleSeat() {
        let alone = Seat(guest: "Solo")
        #expect(RoundTableSeats.seatCount(from: alone) == 1)
        #expect(RoundTableSeats.guests(from: alone) == ["Solo"])
        #expect(!RoundTableSeats.isRoundTable(alone))

        let looped = Seat(guest: "Loop")
        looped.next = looped
        #expect(RoundTableSeats.seatCount(from: looped) == 1)
        #expect(RoundTableSeats.guests(from: looped) == ["Loop"])
        #expect(RoundTableSeats.isRoundTable(looped))
    }

    @Test("A large round table")
    func largeTable() {
        let table = Self.seats(Array(repeating: "Guest", count: 10_000), round: true)
        #expect(RoundTableSeats.seatCount(from: table[5_000]) == 10_000)
        #expect(RoundTableSeats.isRoundTable(table[9_999]))
    }

    @Test("Distinct seats are counted by identity, not by name")
    func distinctSeats() {
        let first = Seat(guest: "Sam")
        let second = Seat(guest: "Sam")
        let third = Seat(guest: "Ali")
        #expect(RoundTableSeats.distinctSeats(in: [first, second, first, first, third, second]) == 3)
        #expect(RoundTableSeats.distinctSeats(in: [first, first, first]) == 1)
        #expect(RoundTableSeats.distinctSeats(in: [first, second]) == 2)
        #expect(RoundTableSeats.distinctSeats(in: []) == 0)
    }
}
