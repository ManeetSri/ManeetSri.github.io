import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ReadingListScreenTests {
    typealias Screen = ReadingListScreen

    let swift6 = Screen.Article(id: 1, title: "Swift 6 in practice")
    let observation = Screen.Article(id: 2, title: "Observation, explained")

    /// Feeds the events to the reducer in order, and collects the effects it asks for
    private func run(_ events: [Screen.Event], from start: Screen.State = Screen.State()) -> (state: Screen.State, effects: [Screen.Effect]) {
        var state = start
        var effects: [Screen.Effect] = []
        for event in events {
            if let effect = Screen.reduce(&state, event) {
                effects.append(effect)
            }
        }
        return (state, effects)
    }

    private var loadedWithSwift6: Screen.State {
        Screen.State(content: .loaded([swift6]), latestRequest: 1)
    }

    @Test("Appearing starts the first load")
    func firstLoad() {
        let (state, effects) = run([.appeared])
        #expect(state.content == .loading)
        #expect(state.latestRequest == 1)
        #expect(effects == [.fetch(request: 1)])
    }

    @Test("Appearing again, while loading or after, doesn't fetch again")
    func appearingTwice() {
        let (state, effects) = run([.appeared, .appeared, .fetchSucceeded(request: 1, articles: [swift6]), .appeared])
        #expect(effects == [.fetch(request: 1)])
        #expect(state == loadedWithSwift6)
    }

    @Test("A successful load shows the articles in order, or the empty state when there are none")
    func loaded() {
        #expect(run([.appeared, .fetchSucceeded(request: 1, articles: [swift6, observation])]).state.content == .loaded([swift6, observation]))
        #expect(run([.appeared, .fetchSucceeded(request: 1, articles: [])]).state.content == .empty)
    }

    @Test("A failed first load shows the error, and retry loads again")
    func failedThenRetry() {
        let failed = run([.appeared, .fetchFailed(request: 1, message: "You're offline")]).state
        #expect(failed == Screen.State(content: .failed(message: "You're offline"), latestRequest: 1))

        let (retrying, effects) = run([.retryTapped], from: failed)
        #expect(retrying.content == .loading)
        #expect(effects == [.fetch(request: 2)])
        #expect(run([.fetchSucceeded(request: 2, articles: [swift6])], from: retrying).state.content == .loaded([swift6]))
    }

    @Test("Pull to refresh keeps the articles on screen until the new ones arrive")
    func refreshKeepsContent() {
        let (refreshing, effects) = run([.refreshPulled], from: loadedWithSwift6)
        #expect(refreshing.content == .loaded([swift6]))
        #expect(refreshing.isRefreshing)
        #expect(effects == [.fetch(request: 2)])

        let done = run([.fetchSucceeded(request: 2, articles: [swift6, observation])], from: refreshing).state
        #expect(done == Screen.State(content: .loaded([swift6, observation]), latestRequest: 2))
    }

    @Test("The empty state can be refreshed into articles")
    func refreshFromEmpty() {
        let (state, effects) = run([.refreshPulled, .fetchSucceeded(request: 2, articles: [observation])], from: Screen.State(content: .empty, latestRequest: 1))
        #expect(effects == [.fetch(request: 2)])
        #expect(state == Screen.State(content: .loaded([observation]), latestRequest: 2))
    }

    @Test("A failed refresh keeps the articles and shows a banner, which can be dismissed")
    func failedRefresh() {
        let failed = run([.refreshPulled, .fetchFailed(request: 2, message: "Couldn't refresh")], from: loadedWithSwift6).state
        #expect(failed == Screen.State(content: .loaded([swift6]), banner: "Couldn't refresh", latestRequest: 2))
        #expect(run([.bannerDismissed], from: failed).state == Screen.State(content: .loaded([swift6]), latestRequest: 2))
    }

    @Test("Pulling again clears the banner, and a successful refresh leaves none")
    func refreshClearsBanner() {
        let failed = Screen.State(content: .loaded([swift6]), banner: "Couldn't refresh", latestRequest: 2)
        let (refreshing, effects) = run([.refreshPulled], from: failed)
        #expect(refreshing.banner == nil)
        #expect(effects == [.fetch(request: 3)])
        #expect(run([.fetchSucceeded(request: 3, articles: [swift6])], from: refreshing).state.banner == nil)
    }

    @Test("A second pull while refreshing doesn't start a second fetch")
    func noDoubleRefresh() {
        let (state, effects) = run([.refreshPulled, .refreshPulled], from: loadedWithSwift6)
        #expect(effects == [.fetch(request: 2)])
        #expect(state.latestRequest == 2)
        #expect(state.isRefreshing)
    }

    @Test("Events that don't fit the screen's state are ignored")
    func ignoredEvents() {
        let (loading, effects) = run([.appeared, .refreshPulled, .retryTapped])
        #expect(loading.content == .loading)
        #expect(effects == [.fetch(request: 1)])

        let (stillLoaded, noEffects) = run([.retryTapped], from: loadedWithSwift6)
        #expect(stillLoaded == loadedWithSwift6)
        #expect(noEffects.isEmpty)
        #expect(run([.refreshPulled]).effects.isEmpty)
    }

    @Test("A late answer to an older request is ignored")
    func staleAnswer() {
        // Request 1 times out, the user retries, and then request 1's answer finally arrives
        let (state, effects) = run([
            .appeared,
            .fetchFailed(request: 1, message: "Timed out"),
            .retryTapped,
            .fetchSucceeded(request: 1, articles: [swift6]),
        ])
        #expect(effects == [.fetch(request: 1), .fetch(request: 2)])
        #expect(state.content == .loading)

        let answered = run([.fetchSucceeded(request: 2, articles: [observation])], from: state).state
        #expect(answered.content == .loaded([observation]))
    }

    @Test("A repeated answer to a request that's already been handled changes nothing")
    func duplicateAnswer() {
        let state = run([.appeared, .fetchSucceeded(request: 1, articles: [swift6]), .fetchFailed(request: 1, message: "Duplicate")]).state
        #expect(state == loadedWithSwift6)
    }
}
