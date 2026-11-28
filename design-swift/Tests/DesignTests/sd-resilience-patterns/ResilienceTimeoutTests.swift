import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ResilienceTimeoutTests {
    private typealias TimedOut = ResilienceTimeout.TimedOut

    private struct ServerError: Error, Equatable {}

    /// A feed request that takes `duration` on the test clock, and logs whether it finished or was cancelled
    private func loadFeed(on clock: TestClock, taking duration: Duration, log: Recorder<String>) -> @Sendable () async throws -> String {
        {
            do {
                try await clock.sleep(for: duration)
            } catch {
                await log.record("cancelled")
                throw error
            }
            await log.record("finished")
            return "feed"
        }
    }

    /// Lets other tasks run until the call has ended, giving up after plenty of rounds so that a wrong
    /// answer fails the test instead of hanging it
    private func waitForOutcome(_ outcome: Recorder<String>) async {
        for _ in 0..<10_000 where await outcome.values.isEmpty {
            await Task.yield()
        }
    }

    /// Lets other tasks run until both the operation and the timer are waiting on the clock (or plenty of
    /// rounds have passed), so moving the clock afterwards is meaningful
    private func waitForSleepers(on clock: TestClock, count: Int = 2) async {
        for _ in 0..<10_000 where clock.sleeperCount < count {
            await Task.yield()
        }
    }

    /// An operation that finishes at once could finish before the timer task has even started, which
    /// makes the test about scheduling rather than timeouts. Quick operations wait for the timer first.
    private static func untilTimerStarts(on clock: TestClock) async {
        for _ in 0..<10_000 where clock.sleeperCount < 1 {
            await Task.yield()
        }
    }

    /// Starts the call in its own task and records how it ended, so a test can watch it while moving the clock
    private func start(within limit: Duration, on clock: TestClock, _ operation: @escaping @Sendable () async throws -> String, outcome: Recorder<String>) -> Task<Void, Never> {
        Task {
            do {
                let value = try await ResilienceTimeout.run(within: limit, clock: clock, operation)
                await outcome.record("value: \(value)")
            } catch let error as TimedOut {
                await outcome.record("timed out after \(error.limit)")
            } catch is CancellationError {
                await outcome.record("cancelled")
            } catch {
                await outcome.record("error: \(error)")
            }
        }
    }

    @Test("A quick operation returns its value and leaves no timer waiting")
    func quickOperation() async throws {
        let clock = TestClock()
        let value = try await ResilienceTimeout.run(within: .seconds(2), clock: clock) {
            await Self.untilTimerStarts(on: clock)
            return 42
        }
        #expect(value == 42)
        await settle()
        #expect(clock.sleeperCount == 0)
    }

    @Test("A slow operation is cancelled when the limit passes, and the call throws TimedOut")
    func slowOperationTimesOut() async {
        let clock = TestClock()
        let log = Recorder<String>()
        let outcome = Recorder<String>()
        _ = start(within: .seconds(2), on: clock, loadFeed(on: clock, taking: .seconds(10), log: log), outcome: outcome)
        await waitForSleepers(on: clock)

        clock.advance(by: .milliseconds(1999))
        await settle()
        #expect(await outcome.values == [])

        clock.advance(by: .milliseconds(1))
        await waitForOutcome(outcome)
        #expect(await outcome.values == ["timed out after 2.0 seconds"])
        #expect(await log.values == ["cancelled"])
        #expect(clock.sleeperCount == 0)
    }

    @Test("Finishing before the limit wins, and the timer is cancelled")
    func finishesInTime() async {
        let clock = TestClock()
        let log = Recorder<String>()
        let outcome = Recorder<String>()
        _ = start(within: .seconds(2), on: clock, loadFeed(on: clock, taking: .seconds(1), log: log), outcome: outcome)
        await waitForSleepers(on: clock)

        clock.advance(by: .seconds(1))
        await waitForOutcome(outcome)
        #expect(await outcome.values == ["value: feed"])
        #expect(await log.values == ["finished"])
        #expect(clock.sleeperCount == 0)
    }

    @Test("The operation's own error comes through unchanged")
    func operationErrorPassesThrough() async {
        let clock = TestClock()
        await #expect(throws: ServerError()) {
            try await ResilienceTimeout.run(within: .seconds(2), clock: clock) { () async throws -> Int in
                await Self.untilTimerStarts(on: clock)
                throw ServerError()
            }
        }
        await settle()
        #expect(clock.sleeperCount == 0)
    }

    @Test("Cancelling the caller cancels the operation, and it isn't reported as a timeout")
    func callerCancellation() async {
        let clock = TestClock()
        let log = Recorder<String>()
        let outcome = Recorder<String>()
        let call = start(within: .seconds(2), on: clock, loadFeed(on: clock, taking: .seconds(10), log: log), outcome: outcome)
        await waitForSleepers(on: clock)

        call.cancel()
        await waitForOutcome(outcome)
        #expect(await outcome.values == ["cancelled"])
        #expect(await log.values == ["cancelled"])
        #expect(clock.sleeperCount == 0)
    }
}
