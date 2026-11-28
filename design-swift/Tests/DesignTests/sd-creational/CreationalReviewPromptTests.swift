import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Prompt = CreationalReviewPrompt

private let day: TimeInterval = 86_400
private let start = Date(timeIntervalSince1970: 1_700_000_000)

/// A clock that only moves when a test moves it
private final class FakeClock {
    var now: Date

    init(_ now: Date = start) {
        self.now = now
    }

    func advance(days: Double) {
        now += days * day
    }

    func advance(seconds: TimeInterval) {
        now += seconds
    }
}

@Suite struct CreationalReviewPromptTests {
    private func prompter(_ store: any Prompt.StateStore, version: String = "1.0", clock: FakeClock) -> Prompt.Prompter {
        Prompt.Prompter(store: store, appVersion: version, now: { clock.now })
    }

    /// Five launches, then enough days for the first prompt
    private func eligible(_ store: any Prompt.StateStore, clock: FakeClock) -> Prompt.Prompter {
        let prompter = prompter(store, clock: clock)
        for _ in 0..<5 {
            prompter.recordLaunch()
        }
        clock.advance(days: 3)
        return prompter
    }

    @Test("Waits for five launches")
    func needsLaunches() {
        let clock = FakeClock()
        let prompter = prompter(Prompt.MemoryStore(), clock: clock)
        for _ in 0..<4 {
            prompter.recordLaunch()
        }
        clock.advance(days: 10)
        #expect(!prompter.shouldPrompt())
        prompter.recordLaunch()
        #expect(prompter.shouldPrompt())
    }

    @Test("Waits three days after the first launch")
    func needsDays() {
        let clock = FakeClock()
        let prompter = prompter(Prompt.MemoryStore(), clock: clock)
        for _ in 0..<5 {
            prompter.recordLaunch()
        }
        #expect(!prompter.shouldPrompt())
        clock.advance(days: 3)
        clock.advance(seconds: -1)
        #expect(!prompter.shouldPrompt())
        clock.advance(seconds: 1)
        #expect(prompter.shouldPrompt())
    }

    @Test("Remembers the first launch, not the latest")
    func firstLaunchOnce() {
        let store = Prompt.MemoryStore()
        let clock = FakeClock()
        let prompter = prompter(store, clock: clock)
        prompter.recordLaunch()
        clock.advance(days: 10)
        prompter.recordLaunch()
        #expect(store.state.launches == 2)
        #expect(store.state.firstLaunch == start)
    }

    @Test("Counts launches across relaunches: prompters sharing a store agree")
    func sharedStore() {
        let store = Prompt.MemoryStore()
        let clock = FakeClock()
        let firstRun = prompter(store, clock: clock)
        for _ in 0..<3 {
            firstRun.recordLaunch()
        }
        let secondRun = prompter(store, clock: clock)
        secondRun.recordLaunch()
        secondRun.recordLaunch()
        clock.advance(days: 3)
        #expect(secondRun.shouldPrompt())
        #expect(firstRun.shouldPrompt())
        #expect(store.state.launches == 5)
    }

    @Test("Separate stores are separate: no state leaks between users or tests")
    func separateStores() {
        let clock = FakeClock()
        let busy = eligible(Prompt.MemoryStore(), clock: clock)
        let fresh = prompter(Prompt.MemoryStore(), clock: clock)
        #expect(busy.shouldPrompt())
        #expect(!fresh.shouldPrompt())
    }

    @Test("Asking records the time and the version")
    func recordsPrompt() {
        let store = Prompt.MemoryStore()
        let clock = FakeClock()
        let prompter = eligible(store, clock: clock)
        prompter.recordPrompt()
        #expect(store.state.lastPrompt == start + 3 * day)
        #expect(store.state.lastPromptVersion == "1.0")
    }

    @Test("Asks at most once per app version")
    func oncePerVersion() {
        let store = Prompt.MemoryStore()
        let clock = FakeClock()
        let prompter = eligible(store, clock: clock)
        #expect(prompter.shouldPrompt())
        prompter.recordPrompt()
        #expect(!prompter.shouldPrompt())
        clock.advance(days: 400)
        #expect(!prompter.shouldPrompt())
    }

    @Test("A new version may ask again, but only 90 days after the last prompt")
    func newVersionWaits() {
        let store = Prompt.MemoryStore()
        let clock = FakeClock()
        eligible(store, clock: clock).recordPrompt()

        let updated = prompter(store, version: "1.1", clock: clock)
        clock.advance(days: 30)
        #expect(!updated.shouldPrompt())
        clock.advance(days: 59)
        #expect(!updated.shouldPrompt())
        clock.advance(days: 1)
        #expect(updated.shouldPrompt())
    }

    @Test("DefaultsStore saves to, and reads from, the UserDefaults it's given")
    func defaultsStore() throws {
        let suite = "CreationalReviewPromptTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = Prompt.DefaultsStore(defaults: defaults)
        #expect(store.load() == Prompt.State())

        let state = Prompt.State(launches: 7, firstLaunch: start, lastPrompt: start + day, lastPromptVersion: "2.0")
        store.save(state)
        #expect(defaults.data(forKey: "reviewPrompt") != nil)
        #expect(Prompt.DefaultsStore(defaults: defaults).load() == state)
    }

    @Test("DefaultsStore uses its key, and starts fresh from unreadable data")
    func defaultsStoreKeys() throws {
        let suite = "CreationalReviewPromptTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        defaults.set(Data("not json".utf8), forKey: "reviewPrompt")
        #expect(Prompt.DefaultsStore(defaults: defaults).load() == Prompt.State())

        let custom = Prompt.DefaultsStore(defaults: defaults, key: "onboardingPrompt")
        custom.save(Prompt.State(launches: 1))
        #expect(defaults.data(forKey: "onboardingPrompt") != nil)
        #expect(custom.load().launches == 1)
    }

    @Test("A prompter over a DefaultsStore survives a relaunch")
    func relaunchWithDefaults() throws {
        let suite = "CreationalReviewPromptTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let clock = FakeClock()
        _ = eligible(Prompt.DefaultsStore(defaults: defaults), clock: clock)
        let relaunched = prompter(Prompt.DefaultsStore(defaults: defaults), clock: clock)
        #expect(relaunched.shouldPrompt())
    }
}
