import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ResilienceDebounceTests {
    /// What a search box sends, the debounced stream, and everything that came out of it
    private struct SearchBox {
        let typed: AsyncStream<String>.Continuation
        let received: Recorder<String>
        let listener: Task<Void, Never>
        let clock: TestClock

        /// Types a value, then lets the debouncer see it (and start its timer) before the test moves the clock
        func type(_ text: String) async {
            typed.yield(text)
            await settle(rounds: 500)
        }

        /// Moves time on, then lets any timer that's due emit
        func wait(_ duration: Duration) async {
            clock.advance(by: duration)
            await settle()
        }

        /// What came out, once at least `count` values have (or after plenty of rounds, so a wrong answer
        /// fails instead of hanging)
        func received(atLeast count: Int) async -> [String] {
            for _ in 0..<10_000 where await received.values.count < count {
                await Task.yield()
            }
            return await received.values
        }
    }

    private static let finished = "<finished>"

    private func searchBox(quiet: Duration = .milliseconds(300)) -> SearchBox {
        let clock = TestClock()
        let (input, typed) = AsyncStream.makeStream(of: String.self)
        let output = ResilienceDebounce.debounce(input, for: quiet, clock: clock)
        let received = Recorder<String>()
        let listener = Task {
            for await value in output {
                await received.record(value)
            }
            await received.record(Self.finished)
        }
        return SearchBox(typed: typed, received: received, listener: listener, clock: clock)
    }

    @Test("A burst of typing emits only the last value, once the quiet period has passed")
    func burstEmitsLast() async {
        let box = searchBox()
        await box.type("s")
        await box.wait(.milliseconds(100))
        await box.type("sw")
        await box.wait(.milliseconds(100))
        await box.type("swi")
        await box.wait(.milliseconds(299))
        #expect(await box.received.values == [])

        await box.wait(.milliseconds(1))
        #expect(await box.received(atLeast: 1) == ["swi"])
        box.listener.cancel()
    }

    @Test("Each new value restarts the quiet period")
    func newValueRestartsTimer() async {
        let box = searchBox()
        await box.type("a")
        await box.wait(.milliseconds(250))
        await box.type("ab")
        await box.wait(.milliseconds(250))
        #expect(await box.received.values == [])
        await box.wait(.milliseconds(50))
        #expect(await box.received(atLeast: 1) == ["ab"])
        box.listener.cancel()
    }

    @Test("Values further apart than the quiet period all come through, in order")
    func spacedValuesPass() async {
        let box = searchBox()
        await box.type("cat")
        await box.wait(.milliseconds(300))
        #expect(await box.received(atLeast: 1) == ["cat"])
        await box.type("cats")
        await box.wait(.milliseconds(400))
        #expect(await box.received(atLeast: 2) == ["cat", "cats"])
        await box.type("catsup")
        await box.wait(.milliseconds(300))
        #expect(await box.received(atLeast: 3) == ["cat", "cats", "catsup"])
        box.listener.cancel()
    }

    @Test("When the input finishes, the waiting value comes out at once, then the stream finishes")
    func finishFlushes() async {
        let box = searchBox()
        await box.type("draft")
        box.typed.finish()
        #expect(await box.received(atLeast: 2) == ["draft", Self.finished])
    }

    @Test("Finishing with nothing waiting just finishes, without repeating the last value")
    func finishWithNothingPending() async {
        let box = searchBox()
        await box.type("done")
        await box.wait(.milliseconds(300))
        #expect(await box.received(atLeast: 1) == ["done"])
        box.typed.finish()
        #expect(await box.received(atLeast: 2) == ["done", Self.finished])
    }

    @Test("When the listener stops, the debouncer stops reading and cancels its timer")
    func listenerStopping() async {
        let box = searchBox()
        await box.type("abandoned")
        #expect(box.clock.sleeperCount == 1)

        box.listener.cancel()
        for _ in 0..<10_000 where box.clock.sleeperCount > 0 {
            await Task.yield()
        }
        await settle()
        #expect(box.clock.sleeperCount == 0)
        var inputEnded = false
        if case .terminated = box.typed.yield("late") { inputEnded = true }
        #expect(inputEnded)
    }
}
