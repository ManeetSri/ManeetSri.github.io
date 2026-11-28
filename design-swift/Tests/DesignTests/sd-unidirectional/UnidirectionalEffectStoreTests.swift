import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@MainActor
@Suite struct UnidirectionalEffectStoreTests {
    private typealias Effect = UnidirectionalEffectStore.Effect<Action>
    private typealias Store = UnidirectionalEffectStore.Store<State, Action>

    private struct State: Equatable {
        var query = ""
        var results: [String] = []
        /// Every query whose results reached the reducer, in order
        var loaded: [String] = []
        var ticks = 0
        var log: [String] = []
    }

    private enum Action: Sendable, Equatable {
        case queryChanged(String)
        case resultsLoaded(query: String, [String])
        case clearTapped
        case startTimer
        case tick
        case stopTimer
        case appeared
        case logged(String)
        case syncTapped
    }

    private struct SyncFailed: Error {}

    /// A search screen with a debounced search, a timer and a few fire-and-forget effects,
    /// all waiting on `clock` so the tests decide when time passes
    private func makeStore(clock: TestClock) -> Store {
        Store(initialState: State()) { state, action in
            switch action {
            case .queryChanged(let query):
                state.query = query
                return .run(id: "search", cancelInFlight: true) { send in
                    try await clock.sleep(for: .milliseconds(300))
                    await send(.resultsLoaded(query: query, ["\(query) result"]))
                }
            case .resultsLoaded(let query, let results):
                state.results = results
                state.loaded.append(query)
                return .none
            case .clearTapped:
                state.query = ""
                state.results = []
                return .merge([.cancel(id: "search"), .send(.logged("cleared"))])
            case .startTimer:
                return .run(id: "timer") { send in
                    for _ in 0..<100 {
                        try await clock.sleep(for: .seconds(1))
                        await send(.tick)
                    }
                }
            case .tick:
                state.ticks += 1
                return .none
            case .stopTimer:
                return .cancel(id: "timer")
            case .appeared:
                return .merge([
                    .run { send in await send(.logged("analytics")) },
                    .run { send in await send(.logged("prefetch")) },
                ])
            case .logged(let line):
                state.log.append(line)
                return .none
            case .syncTapped:
                return .run { _ in
                    try await clock.sleep(for: .seconds(1))
                    throw SyncFailed()
                }
            }
        }
    }

    /// Lets effect tasks run until `condition` holds. Bounded, so a wrong answer fails instead of hanging.
    private func waitUntil(_ condition: () -> Bool) async {
        for _ in 0..<2_000 where !condition() {
            await Task.yield()
        }
        await settle()
    }

    @Test("An effect runs, and the action it sends is reduced on the main actor")
    func runsEffectAndFeedsActionBack() async {
        let clock = TestClock()
        let store = makeStore(clock: clock)
        store.send(.queryChanged("dune"))
        #expect(store.state.query == "dune")
        #expect(store.runningEffects == 1)

        await waitUntil { clock.sleeperCount == 1 }
        clock.advance(by: .milliseconds(300))
        await waitUntil { store.runningEffects == 0 }
        #expect(store.state.results == ["dune result"])
        #expect(store.runningEffects == 0)
    }

    @Test("cancelInFlight: typing quickly cancels the searches that are still waiting")
    func cancelInFlight() async {
        let clock = TestClock()
        let store = makeStore(clock: clock)
        for query in ["d", "du", "dun"] {
            store.send(.queryChanged(query))
            #expect(store.runningEffects == 1)
            await settle()
            clock.advance(by: .milliseconds(100))
            await settle()
        }
        clock.advance(by: .milliseconds(300))
        await waitUntil { !store.state.loaded.isEmpty }
        #expect(store.state.loaded == ["dun"])
        #expect(store.state.results == ["dun result"])
        #expect(store.runningEffects == 0)
    }

    @Test(".cancel(id:) stops a running effect, and its action never arrives")
    func cancelByID() async {
        let clock = TestClock()
        let store = makeStore(clock: clock)
        store.send(.queryChanged("dune"))
        await waitUntil { clock.sleeperCount == 1 }
        store.send(.clearTapped)
        #expect(store.runningEffects == 0)
        #expect(store.state.log == ["cleared"], ".send in a merge is reduced before send returns")

        clock.advance(by: .seconds(1))
        await settle()
        #expect(store.state.loaded.isEmpty)
        #expect(store.state.results.isEmpty)
    }

    @Test("A cancelled effect that finishes late doesn't remove the effect that replaced it")
    func cancelledEffectKeepsItsReplacement() async {
        let clock = TestClock()
        let store = makeStore(clock: clock)
        store.send(.queryChanged("du"))
        await waitUntil { clock.sleeperCount == 1 }
        store.send(.queryChanged("dune"))
        // The search for "du" ends now that it's cancelled. The search for "dune" must still be known by its id.
        await waitUntil { clock.sleeperCount == 1 }
        await settle()
        #expect(store.runningEffects == 1)

        store.send(.clearTapped)
        #expect(store.runningEffects == 0)
        clock.advance(by: .seconds(1))
        await settle()
        #expect(store.state.loaded.isEmpty, "the search for \"dune\" should have been cancelled by clearTapped")
    }

    @Test("A long-running effect keeps sending until it's cancelled")
    func longRunningTimer() async {
        let clock = TestClock()
        let store = makeStore(clock: clock)
        store.send(.startTimer)
        for expected in 1...3 {
            await waitUntil { clock.sleeperCount == 1 }
            clock.advance(by: .seconds(1))
            await waitUntil { store.state.ticks == expected }
        }
        #expect(store.state.ticks == 3)
        #expect(store.runningEffects == 1)

        store.send(.stopTimer)
        #expect(store.runningEffects == 0)
        clock.advance(by: .seconds(5))
        await settle()
        #expect(store.state.ticks == 3)
    }

    @Test("Effects without an id run side by side, and cancelling an id leaves them alone")
    func independentEffects() async {
        let clock = TestClock()
        let store = makeStore(clock: clock)
        store.send(.startTimer)
        store.send(.appeared)
        await waitUntil { store.state.log.count == 2 && store.runningEffects == 1 }
        #expect(Set(store.state.log) == ["analytics", "prefetch"])

        store.send(.clearTapped)
        #expect(store.runningEffects == 1, "the timer has a different id, so it keeps running")
        store.send(.stopTimer)
    }

    @Test("An effect that throws simply ends")
    func throwingEffectEnds() async {
        let clock = TestClock()
        let store = makeStore(clock: clock)
        store.send(.syncTapped)
        #expect(store.runningEffects == 1)
        await waitUntil { clock.sleeperCount == 1 }
        clock.advance(by: .seconds(1))
        await waitUntil { store.runningEffects == 0 }
        #expect(store.runningEffects == 0)
        #expect(store.state == State())
    }
}
