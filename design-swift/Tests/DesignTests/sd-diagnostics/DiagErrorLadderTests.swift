import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct DiagErrorLadderTests {
    typealias Ladder = DiagErrorLadder
    typealias Transport = DiagErrorLadder.TransportError
    typealias Orders = DiagErrorLadder.OrdersError
    typealias Presentation = DiagErrorLadder.Presentation

    @Test("Transport failures that aren't statuses", arguments: [
        (Transport.notConnected, Orders.offline),
        (.timedOut, .unavailable(retryAfter: nil)),
        (.cancelled, .cancelled),
        (.undecodable, .contractBroken),
    ])
    func transportKinds(transport: Transport, expected: Orders) {
        #expect(Ladder.ordersError(for: transport) == expected)
    }

    @Test("Statuses map by what they mean for orders", arguments: [
        (401, Orders.sessionExpired),
        (404, .notFound),
        (410, .notFound),
        (400, .rejected(status: 400)),
        (403, .rejected(status: 403)),
        (418, .rejected(status: 418)),
        (422, .rejected(status: 422)),
        (500, .serverFault),
        (501, .serverFault),
        (302, .contractBroken),
        (200, .contractBroken),
        (600, .contractBroken),
    ])
    func statuses(code: Int, expected: Orders) {
        #expect(Ladder.ordersError(for: .status(code, retryAfter: nil)) == expected)
    }

    @Test("Busy statuses keep the server's Retry-After", arguments: [408, 429, 502, 503, 504])
    func busyStatuses(code: Int) {
        #expect(Ladder.ordersError(for: .status(code, retryAfter: 12)) == .unavailable(retryAfter: 12))
        #expect(Ladder.ordersError(for: .status(code, retryAfter: nil)) == .unavailable(retryAfter: nil))
    }

    @Test("Each orders error has one presentation")
    func presentations() {
        #expect(Ladder.presentation(for: .offline, attempt: 1) == Presentation(message: .offline, retry: .whenOnline, report: false))
        #expect(Ladder.presentation(for: .sessionExpired, attempt: 1) == Presentation(message: .signInAgain, retry: .signIn, report: false))
        #expect(Ladder.presentation(for: .notFound, attempt: 1) == Presentation(message: .notFound, retry: .none, report: false))
        #expect(Ladder.presentation(for: .serverFault, attempt: 1) == Presentation(message: .generic, retry: .button, report: false))
    }

    @Test("Failures the app probably caused are reported and not retried")
    func appAtFault() {
        #expect(Ladder.presentation(for: .rejected(status: 422), attempt: 1) == Presentation(message: .generic, retry: .none, report: true))
        #expect(Ladder.presentation(for: .contractBroken, attempt: 1) == Presentation(message: .generic, retry: .none, report: true))
    }

    @Test("Cancellation shows nothing")
    func cancellation() {
        #expect(Ladder.presentation(for: .cancelled, attempt: 1) == nil)
        #expect(Ladder.presentation(for: .cancelled, attempt: 5) == nil)
    }

    @Test("Busy retries automatically with backoff, then hands the user a button")
    func busyBackoff() {
        #expect(Ladder.presentation(for: .unavailable(retryAfter: nil), attempt: 1)?.retry == .automatically(afterSeconds: 2))
        #expect(Ladder.presentation(for: .unavailable(retryAfter: nil), attempt: 2)?.retry == .automatically(afterSeconds: 4))
        #expect(Ladder.presentation(for: .unavailable(retryAfter: nil), attempt: 3) == Presentation(message: .busy, retry: .button, report: false))
        #expect(Ladder.presentation(for: .unavailable(retryAfter: 5), attempt: 7)?.retry == .button)
    }

    @Test("The server's Retry-After wins, kept between 1 and 60 seconds")
    func retryAfter() {
        #expect(Ladder.presentation(for: .unavailable(retryAfter: 30), attempt: 1) == Presentation(message: .busy, retry: .automatically(afterSeconds: 30), report: false))
        #expect(Ladder.presentation(for: .unavailable(retryAfter: 600), attempt: 1)?.retry == .automatically(afterSeconds: 60))
        #expect(Ladder.presentation(for: .unavailable(retryAfter: 0), attempt: 2)?.retry == .automatically(afterSeconds: 1))
    }

    @Test("An attempt below 1 counts as the first")
    func attemptFloor() {
        #expect(Ladder.presentation(for: .unavailable(retryAfter: nil), attempt: 0)?.retry == .automatically(afterSeconds: 2))
    }

    @Test("load passes a success straight through")
    func loadSuccess() async throws {
        let value = try await Ladder.load { () async throws(Transport) -> Int in 42 }
        #expect(value == 42)
    }

    @Test("load rethrows transport failures as orders errors", arguments: [
        (Transport.status(404, retryAfter: nil), Orders.notFound),
        (.notConnected, .offline),
        (.cancelled, .cancelled),
        (.status(503, retryAfter: 9), .unavailable(retryAfter: 9)),
    ])
    func loadMapsFailures(transport: Transport, expected: Orders) async {
        do {
            _ = try await Ladder.load { () async throws(Transport) -> String in throw transport }
            Issue.record("load should have thrown")
        } catch {
            #expect(error == expected)
        }
    }

    @Test("The whole ladder, from a 503 to a countdown on screen")
    func endToEnd() async {
        do {
            _ = try await Ladder.load { () async throws(Transport) -> String in throw .status(503, retryAfter: 12) }
            Issue.record("load should have thrown")
        } catch {
            #expect(Ladder.presentation(for: error, attempt: 1) == Presentation(message: .busy, retry: .automatically(afterSeconds: 12), report: false))
        }
    }
}
