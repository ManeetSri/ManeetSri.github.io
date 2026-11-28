import DesignKit
import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@MainActor @Suite struct SolidReviewPromptTests {
    typealias History = SolidReviewPrompt.History

    /// A fake of the policy's own HistoryStore protocol: no UserDefaults anywhere
    private actor MemoryHistory: SolidReviewPrompt.HistoryStore {
        var history: History

        init(_ history: History = History()) {
            self.history = history
        }

        func load() -> History { history }
        func save(_ history: History) { self.history = history }
    }

    /// Counts prompts instead of showing StoreKit's
    private final class CountingRequester: SolidReviewPrompt.ReviewRequesting {
        var count = 0
        func requestReview() { count += 1 }
    }

    private static func day(_ number: Double) -> Date {
        Date(timeIntervalSinceReferenceDate: 800_000_000 + number * 86_400)
    }

    private func policy(_ store: any SolidReviewPrompt.HistoryStore, _ requester: CountingRequester, version: String = "2.0", day number: Double = 0) -> SolidReviewPrompt.ReviewPromptPolicy {
        let date = Self.day(number)
        return SolidReviewPrompt.ReviewPromptPolicy(store: store, requester: requester, appVersion: version, now: { date })
    }

    @Test("Asks on the third completed order, not before")
    func thirdOrder() async {
        let requester = CountingRequester()
        let subject = policy(MemoryHistory(), requester)
        var answers: [Bool] = []
        for _ in 0..<3 { answers.append(await subject.orderCompleted()) }
        #expect(answers == [false, false, true])
        #expect(requester.count == 1)
    }

    @Test("Remembers what it did: the order count and when, and in which version, it asked")
    func savesHistory() async {
        let store = MemoryHistory(History(completedOrders: 2))
        let asked = await policy(store, CountingRequester(), version: "2.1", day: 10).orderCompleted()
        #expect(asked)
        #expect(await store.history == History(completedOrders: 3, lastPromptDate: Self.day(10), lastPromptVersion: "2.1"))
    }

    @Test("Never asks twice in one version, however long it's been")
    func oncePerVersion() async {
        let store = MemoryHistory(History(completedOrders: 2))
        let requester = CountingRequester()
        #expect(await policy(store, requester, version: "2.0", day: 0).orderCompleted())
        #expect(await policy(store, requester, version: "2.0", day: 1).orderCompleted() == false)
        #expect(await policy(store, requester, version: "2.0", day: 400).orderCompleted() == false)
        #expect(requester.count == 1)
        #expect(await store.history.completedOrders == 5)
    }

    @Test("A new version waits until 120 days after the last prompt")
    func gapBetweenPrompts() async {
        let store = MemoryHistory(History(completedOrders: 9, lastPromptDate: Self.day(0), lastPromptVersion: "2.0"))
        let requester = CountingRequester()
        #expect(await policy(store, requester, version: "2.1", day: 30).orderCompleted() == false)
        #expect(await policy(store, requester, version: "2.1", day: 119.9).orderCompleted() == false)
        #expect(await policy(store, requester, version: "2.1", day: 120).orderCompleted())
        #expect(requester.count == 1)
    }

    @Test("A problem in this launch holds the prompt back until the next launch")
    func problemThisLaunch() async {
        let store = MemoryHistory(History(completedOrders: 2))
        let requester = CountingRequester()
        let troubled = policy(store, requester)
        troubled.noteProblem()
        #expect(await troubled.orderCompleted() == false)
        #expect(await store.history.completedOrders == 3)
        #expect(await policy(store, requester).orderCompleted())
        #expect(requester.count == 1)
    }

    @Test("The key-value adapter saves the history as JSON and reads it back")
    func adapterRoundTrip() async throws {
        let backing = InMemoryKeyValueStore()
        let adapter = SolidReviewPrompt.KeyValueHistoryStore(backing)
        #expect(await adapter.load() == History())
        let history = History(completedOrders: 4, lastPromptDate: Self.day(3), lastPromptVersion: "2.0")
        await adapter.save(history)
        #expect(await adapter.load() == history)
        let data = try #require(await backing.data(for: SolidReviewPrompt.KeyValueHistoryStore.key))
        #expect(try JSONDecoder().decode(History.self, from: data) == history)
    }

    @Test("Unreadable data counts as no history")
    func adapterCorruptData() async {
        let backing = InMemoryKeyValueStore([SolidReviewPrompt.KeyValueHistoryStore.key: Data("not json".utf8)])
        let adapter = SolidReviewPrompt.KeyValueHistoryStore(backing)
        #expect(await adapter.load() == History())
        await adapter.save(History(completedOrders: 1))
        #expect(await adapter.load() == History(completedOrders: 1))
    }

    @Test("Policy and adapter together: a relaunch remembers the prompt")
    func acrossLaunches() async {
        let backing = InMemoryKeyValueStore()
        let requester = CountingRequester()
        let firstLaunch = policy(SolidReviewPrompt.KeyValueHistoryStore(backing), requester)
        for _ in 0..<3 { _ = await firstLaunch.orderCompleted() }
        #expect(requester.count == 1)
        let relaunch = policy(SolidReviewPrompt.KeyValueHistoryStore(backing), requester, day: 1)
        #expect(await relaunch.orderCompleted() == false)
        #expect(requester.count == 1)
        #expect(await SolidReviewPrompt.KeyValueHistoryStore(backing).load().completedOrders == 4)
    }
}
