import DesignKit
import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ResilienceCircuitBreakerTests {
    private typealias Breaker = ResilienceCircuitBreaker.Breaker<TestClock>
    private typealias CircuitOpen = ResilienceCircuitBreaker.CircuitOpen

    private struct ServerDown: Error {}

    /// Counts how many times an operation really ran, as opposed to being turned away
    private actor Calls {
        private(set) var count = 0
        func hit() { count += 1 }
    }

    /// Holds a trial call open until the test lets it finish
    private actor Latch {
        private var isOpen = false
        private var waiters: [CheckedContinuation<Void, Never>] = []

        func wait() async {
            if isOpen { return }
            await withCheckedContinuation { waiters.append($0) }
        }

        func open() {
            isOpen = true
            waiters.forEach { $0.resume() }
            waiters.removeAll()
        }
    }

    private func succeed(_ breaker: Breaker, calls: Calls) async throws -> Int {
        try await breaker.run {
            await calls.hit()
            return 200
        }
    }

    private func fail(_ breaker: Breaker, times: Int = 1, calls: Calls, with error: any Error = ServerDown()) async {
        for _ in 0..<times {
            _ = try? await breaker.run { () async throws -> Int in
                await calls.hit()
                throw error
            }
        }
    }

    @Test("A closed breaker runs every call and hands back its result")
    func closedPassesThrough() async throws {
        let breaker = Breaker(failureThreshold: 3, cooldown: .seconds(10), clock: TestClock())
        let calls = Calls()
        #expect(try await succeed(breaker, calls: calls) == 200)
        #expect(try await succeed(breaker, calls: calls) == 200)
        #expect(await calls.count == 2)
        #expect(await breaker.state == .closed)
    }

    @Test("Failures pass through unchanged, and the threshold in a row opens the breaker")
    func opensAtThreshold() async throws {
        let breaker = Breaker(failureThreshold: 3, cooldown: .seconds(10), clock: TestClock())
        let calls = Calls()
        await #expect(throws: ServerDown.self) {
            try await breaker.run { () async throws -> Int in throw ServerDown() }
        }
        await fail(breaker, times: 1, calls: calls)
        #expect(await breaker.state == .closed)
        await fail(breaker, times: 1, calls: calls)
        #expect(await breaker.state == .open)
    }

    @Test("An open breaker fails fast without running the operation")
    func openFailsFast() async throws {
        let breaker = Breaker(failureThreshold: 2, cooldown: .seconds(10), clock: TestClock())
        let calls = Calls()
        await fail(breaker, times: 2, calls: calls)
        #expect(await calls.count == 2)
        await #expect(throws: CircuitOpen.self) {
            _ = try await succeed(breaker, calls: calls)
        }
        #expect(await calls.count == 2)
    }

    @Test("A success resets the count: only failures in a row open it")
    func successResets() async throws {
        let breaker = Breaker(failureThreshold: 3, cooldown: .seconds(10), clock: TestClock())
        let calls = Calls()
        await fail(breaker, times: 2, calls: calls)
        _ = try await succeed(breaker, calls: calls)
        await fail(breaker, times: 2, calls: calls)
        #expect(await breaker.state == .closed)
        await fail(breaker, times: 1, calls: calls)
        #expect(await breaker.state == .open)
    }

    @Test("After the cooldown it's half-open, and a successful trial closes it")
    func trialSuccessCloses() async throws {
        let clock = TestClock()
        let breaker = Breaker(failureThreshold: 2, cooldown: .seconds(10), clock: clock)
        let calls = Calls()
        await fail(breaker, times: 2, calls: calls)

        clock.advance(by: .seconds(9))
        #expect(await breaker.state == .open)
        await #expect(throws: CircuitOpen.self) {
            _ = try await succeed(breaker, calls: calls)
        }

        clock.advance(by: .seconds(1))
        #expect(await breaker.state == .halfOpen)
        #expect(try await succeed(breaker, calls: calls) == 200)
        #expect(await breaker.state == .closed)
        #expect(await calls.count == 3)

        // Closed again with a clean count: one failure doesn't reopen it
        await fail(breaker, times: 1, calls: calls)
        #expect(await breaker.state == .closed)
    }

    @Test("A failed trial reopens it for another full cooldown, counted from the failure")
    func trialFailureReopens() async throws {
        let clock = TestClock()
        let breaker = Breaker(failureThreshold: 2, cooldown: .seconds(10), clock: clock)
        let calls = Calls()
        await fail(breaker, times: 2, calls: calls)

        clock.advance(by: .seconds(15))
        await fail(breaker, times: 1, calls: calls)
        #expect(await breaker.state == .open)
        #expect(await calls.count == 3)

        clock.advance(by: .seconds(9))
        #expect(await breaker.state == .open)
        clock.advance(by: .seconds(1))
        #expect(await breaker.state == .halfOpen)
    }

    @Test("While a trial is running, every other call is turned away")
    func oneTrialAtATime() async throws {
        let clock = TestClock()
        let breaker = Breaker(failureThreshold: 1, cooldown: .seconds(5), clock: clock)
        let calls = Calls()
        let latch = Latch()
        await fail(breaker, times: 1, calls: calls)
        clock.advance(by: .seconds(5))

        let trial = Task {
            try await breaker.run {
                await calls.hit()
                await latch.wait()
                return 200
            }
        }
        // Wait until the trial is under way (bounded, so a wrong answer fails rather than hangs)
        for _ in 0..<10_000 where await calls.count < 2 {
            await Task.yield()
        }
        #expect(await breaker.state == .halfOpen)
        await #expect(throws: CircuitOpen.self) {
            _ = try await succeed(breaker, calls: calls)
        }
        #expect(await calls.count == 2)

        await latch.open()
        #expect(try await trial.value == 200)
        #expect(await breaker.state == .closed)
    }

    @Test("Cancellations aren't failures: the caller gave up, the server didn't")
    func cancellationsDontCount() async throws {
        let breaker = Breaker(failureThreshold: 2, cooldown: .seconds(10), clock: TestClock())
        let calls = Calls()
        await fail(breaker, times: 3, calls: calls, with: CancellationError())
        await fail(breaker, times: 3, calls: calls, with: URLError(.cancelled))
        #expect(await breaker.state == .closed)
        #expect(await calls.count == 6)
        await fail(breaker, times: 2, calls: calls, with: URLError(.timedOut))
        #expect(await breaker.state == .open)
    }
}
