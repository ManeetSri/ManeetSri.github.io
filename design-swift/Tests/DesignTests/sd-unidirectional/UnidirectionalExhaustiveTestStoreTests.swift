import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A plant-care feature: watering syncs to a server, a reminder fires after a minute, and a banner can be dismissed
@MainActor
@Suite struct UnidirectionalExhaustiveTestStoreTests {
    private typealias TestStore = UnidirectionalExhaustiveTestStore.TestStore<Plant, PlantAction>
    private typealias Failure = UnidirectionalExhaustiveTestStore.Failure<Plant, PlantAction>
    private typealias Effect = UnidirectionalExhaustiveTestStore.Effect<PlantAction>

    private struct Plant: Equatable, Sendable {
        var waterings = 0
        var isSyncing = false
        var banner: String?
        var remindersSet = 0
    }

    private enum PlantAction: Equatable, Sendable {
        case waterTapped
        case syncFinished(waterings: Int)
        case bannerDismissed
        case bannerCleared
        case remindMeTapped
        case reminderFired
        case peeked
    }

    private func makeStore(clock: TestClock = TestClock(), initialState: Plant = Plant()) -> TestStore {
        TestStore(initialState: initialState) { state, action in
            switch action {
            case .waterTapped:
                state.waterings += 1
                state.isSyncing = true
                let waterings = state.waterings
                return .run { .syncFinished(waterings: waterings) }
            case .syncFinished(let waterings):
                state.isSyncing = false
                state.banner = "Waterings: \(waterings)"
                return .none
            case .bannerDismissed:
                return .send(.bannerCleared)
            case .bannerCleared:
                state.banner = nil
                return .none
            case .remindMeTapped:
                state.remindersSet += 1
                return .merge([
                    .run {
                        try? await clock.sleep(for: .seconds(60))
                        return .reminderFired
                    },
                    .run { nil },
                ])
            case .reminderFired:
                state.banner = "Time to water"
                return .none
            case .peeked:
                return .none
            }
        }
    }

    /// Lets effect tasks run until `condition` holds. Bounded, so a wrong answer fails instead of hanging.
    private func waitUntil(_ condition: () -> Bool) async {
        for _ in 0..<2_000 where !condition() {
            await Task.yield()
        }
    }

    @Test("A test that asserts every change and every action passes with no failures")
    func passingTest() async {
        let store = makeStore()
        await store.send(.waterTapped) {
            $0.waterings = 1
            $0.isSyncing = true
        }
        await store.receive(.syncFinished(waterings: 1)) {
            $0.isSyncing = false
            $0.banner = "Waterings: 1"
        }
        await store.send(.bannerDismissed)
        await store.receive(.bannerCleared) {
            $0.banner = nil
        }
        await store.finish()
        #expect(store.failures == [])
        #expect(store.state == Plant(waterings: 1))
    }

    @Test("A state change the test didn't describe is a failure, showing expected and actual")
    func missingStateAssertion() async {
        let store = makeStore()
        await store.send(.waterTapped) {
            $0.waterings = 1
        }
        #expect(store.failures == [
            .stateMismatch(after: .waterTapped, expected: Plant(waterings: 1), actual: Plant(waterings: 1, isSyncing: true)),
        ])
        #expect(store.state == Plant(waterings: 1, isSyncing: true))
    }

    @Test("Leaving out the closure says nothing changes")
    func noClosureMeansNoChange() async {
        let store = makeStore()
        await store.send(.peeked)
        #expect(store.failures == [])

        await store.send(.remindMeTapped)
        #expect(store.failures == [
            .stateMismatch(after: .remindMeTapped, expected: Plant(), actual: Plant(remindersSet: 1)),
        ])
        await store.finish()
    }

    @Test("Sending again before receiving the feature's own actions is a failure")
    func unhandledReceivedActions() async {
        let store = makeStore()
        await store.send(.waterTapped) {
            $0.waterings = 1
            $0.isSyncing = true
        }
        await waitUntil { store.runningEffects == 0 }
        await store.send(.peeked)
        #expect(store.failures == [
            .receivedActionsNotHandled(before: .peeked, pending: [.syncFinished(waterings: 1)]),
        ])
        #expect(store.state == Plant(waterings: 1, isSyncing: true))
    }

    @Test("Receiving a different action than the one that arrived is a failure, and changes nothing")
    func unexpectedAction() async {
        let store = makeStore()
        await store.send(.waterTapped) {
            $0.waterings = 1
            $0.isSyncing = true
        }
        await store.receive(.reminderFired) {
            $0.banner = "Time to water"
        }
        #expect(store.failures == [
            .unexpectedAction(expected: .reminderFired, received: .syncFinished(waterings: 1)),
        ])
        #expect(store.state == Plant(waterings: 1, isSyncing: true))
    }

    @Test("Expecting an action that never comes is a failure; once time passes, it arrives")
    func waitsForTime() async {
        let clock = TestClock()
        let store = makeStore(clock: clock)
        await store.send(.remindMeTapped) {
            $0.remindersSet = 1
        }
        await waitUntil { clock.sleeperCount == 1 }
        await store.receive(.reminderFired)
        #expect(store.failures == [.noActionReceived(expected: .reminderFired)])

        clock.advance(by: .seconds(60))
        await store.receive(.reminderFired) {
            $0.banner = "Time to water"
        }
        await store.finish()
        #expect(store.failures == [.noActionReceived(expected: .reminderFired)])
        #expect(store.state == Plant(banner: "Time to water", remindersSet: 1))
    }

    @Test("Finishing with an effect still running is a failure, and the effect is cancelled")
    func effectsStillRunning() async {
        let clock = TestClock()
        let store = makeStore(clock: clock)
        await store.send(.remindMeTapped) {
            $0.remindersSet = 1
        }
        await waitUntil { clock.sleeperCount == 1 }
        #expect(store.runningEffects == 1)

        await store.finish()
        #expect(store.failures == [.effectsStillRunning(1)])
        #expect(store.runningEffects == 0)
        #expect(clock.sleeperCount == 0, "finish cancels what's still running")
    }

    @Test("Finishing with actions the test never received is a failure")
    func unreceivedActionsAtFinish() async {
        let store = makeStore()
        await store.send(.bannerDismissed)
        await store.finish()
        #expect(store.failures == [.unreceivedActions([.bannerCleared])])
    }

    @Test("A received action is reduced and checked like a sent one")
    func receivedActionsRunEffects() async {
        let store = makeStore(initialState: Plant(waterings: 2, banner: "Waterings: 2"))
        await store.send(.bannerDismissed)
        await store.receive(.bannerCleared) {
            $0.banner = nil
        }
        await store.send(.waterTapped) {
            $0.waterings = 3
            $0.isSyncing = true
        }
        await store.receive(.syncFinished(waterings: 3)) {
            $0.isSyncing = true
        }
        await store.finish()
        #expect(store.failures == [
            .stateMismatch(
                after: .syncFinished(waterings: 3),
                expected: Plant(waterings: 3, isSyncing: true),
                actual: Plant(waterings: 3, banner: "Waterings: 3")
            ),
        ])
        #expect(store.state == Plant(waterings: 3, banner: "Waterings: 3"))
    }
}
