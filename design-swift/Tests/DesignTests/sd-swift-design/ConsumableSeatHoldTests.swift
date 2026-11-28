import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias BoxOffice = ConsumableSeatHold.BoxOffice
private typealias HoldError = ConsumableSeatHold.HoldError

/// The books as one value, so each test compares them in a single expectation
private struct Books: Equatable {
    let available: Int
    let held: Int
    let sold: Int
}

private func books(_ office: BoxOffice) -> Books {
    Books(available: office.available, held: office.held, sold: office.sold)
}

@Suite struct ConsumableSeatHoldTests {
    @Test("A hold moves seats from available to held")
    func holding() throws {
        let office = BoxOffice(seats: 10)
        let hold = try office.hold(3, for: 60)
        let seats = hold.seats
        #expect(seats == 3)
        #expect(books(office) == Books(available: 7, held: 3, sold: 0))
        hold.release()
    }

    @Test("Confirming sells the held seats and returns a receipt for the hold")
    func confirming() throws {
        let office = BoxOffice(seats: 10)
        let hold = try office.hold(4, for: 60)
        let id = hold.id
        let receipt = try hold.confirm()
        #expect(receipt == ConsumableSeatHold.Receipt(holdID: id, seats: 4))
        #expect(books(office) == Books(available: 6, held: 0, sold: 4))
    }

    @Test("Releasing gives the seats back")
    func releasing() throws {
        let office = BoxOffice(seats: 10)
        let hold = try office.hold(5, for: 60)
        hold.release()
        #expect(books(office) == Books(available: 10, held: 0, sold: 0))
    }

    @Test("A hold that's dropped without being settled gives its seats back")
    func dropping() throws {
        let office = BoxOffice(seats: 10)
        // The customer looks at the seats and closes the app: the hold's life ends with the function
        func browseAndLeave() throws {
            let hold = try office.hold(2, for: 60)
            let seats = hold.seats
            #expect(seats == 2)
            #expect(books(office) == Books(available: 8, held: 2, sold: 0))
        }
        try browseAndLeave()
        #expect(books(office) == Books(available: 10, held: 0, sold: 0))
    }

    @Test("Holding more seats than are available throws soldOut and changes nothing")
    func soldOut() throws {
        let office = BoxOffice(seats: 4)
        let first = try office.hold(3, for: 60)
        #expect(throws: HoldError.soldOut) {
            _ = try office.hold(2, for: 60)
        }
        #expect(books(office) == Books(available: 1, held: 3, sold: 0))
        _ = try first.confirm()
        #expect(books(office) == Books(available: 1, held: 0, sold: 3))
    }

    @Test("The thrown error is a HoldError, so it can be switched over without a default")
    func typedErrors() {
        let office = BoxOffice(seats: 1)
        var outcome = "no error"
        do {
            _ = try office.hold(5, for: 60)
        } catch {
            switch error {
            case .soldOut: outcome = "sold out"
            case .expired: outcome = "expired"
            }
        }
        #expect(outcome == "sold out")
    }

    @Test("Confirming after the hold expires throws expired and gives the seats back")
    func expiry() throws {
        let office = BoxOffice(seats: 10)
        let hold = try office.hold(4, for: 30)
        let expiresAt = hold.expiresAt
        #expect(expiresAt == 30)
        office.advance(by: 30)
        // A consuming call can't happen inside a closure that captures the hold, so catch it here
        var thrown: HoldError?
        do {
            _ = try hold.confirm()
        } catch {
            thrown = error
        }
        #expect(thrown == .expired)
        #expect(books(office) == Books(available: 10, held: 0, sold: 0))
    }

    @Test("A hold confirmed just before its deadline still sells")
    func justInTime() throws {
        let office = BoxOffice(seats: 10)
        office.advance(by: 100)
        let hold = try office.hold(1, for: 30)
        let expiresAt = hold.expiresAt
        #expect(expiresAt == 130)
        office.advance(by: 29)
        _ = try hold.confirm()
        #expect(books(office) == Books(available: 9, held: 0, sold: 1))
    }

    @Test("Holds get their own ids and settle independently")
    func independentHolds() throws {
        let office = BoxOffice(seats: 10)
        let a = try office.hold(2, for: 60)
        let b = try office.hold(3, for: 60)
        let firstID = a.id
        let secondID = b.id
        #expect(firstID == 1)
        #expect(secondID == 2)
        let receipt = try a.confirm()
        b.release()
        #expect(receipt.holdID == 1)
        #expect(books(office) == Books(available: 8, held: 0, sold: 2))
    }
}
