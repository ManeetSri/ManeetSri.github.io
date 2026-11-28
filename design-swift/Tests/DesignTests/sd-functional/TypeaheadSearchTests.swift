import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TypeaheadSearchTests {
    private typealias Search = TypeaheadSearch

    /// Feeds the actions to the reducer in order, collecting every effect it asks for
    private func run(_ actions: [Search.Action], from start: Search.State = .init()) -> (state: Search.State, effects: [Search.Effect]) {
        var state = start
        var effects: [Search.Effect] = []
        for action in actions {
            effects += Search.reduce(&state, action)
        }
        return (state, effects)
    }

    @Test("Typing a query starts a search and shows loading")
    func startsSearch() {
        var state = Search.State()
        let effects = Search.reduce(&state, .queryChanged("swift"))
        #expect(effects == [.search(id: 1, query: "swift")])
        #expect(state.query == "swift")
        #expect(state.isLoading)
    }

    @Test("Spaces around the query are trimmed and don't start a second search")
    func trimsWhitespace() {
        let (state, effects) = run([.queryChanged("  swift"), .queryChanged("swift \n")])
        #expect(effects == [.search(id: 1, query: "swift")])
        #expect(state.query == "swift")
    }

    @Test("The newest search's results replace the old ones")
    func showsResults() {
        let (state, effects) = run([
            .queryChanged("swi"), .searchFinished(id: 1, .success(["Swift"])),
            .queryChanged("swift t"), .searchFinished(id: 2, .success(["Swift Testing", "Swift Tour"])),
        ])
        #expect(effects == [.search(id: 1, query: "swi"), .search(id: 2, query: "swift t")])
        #expect(state.results == ["Swift Testing", "Swift Tour"])
        #expect(!state.isLoading)
        #expect(state.errorMessage == nil)
    }

    @Test("A slow response to an older query is ignored")
    func ignoresStaleResponses() {
        let (state, effects) = run([
            .queryChanged("sw"),
            .queryChanged("swi"),
            .searchFinished(id: 1, .success(["Sweden", "Swimming"])),
        ])
        #expect(effects == [.search(id: 1, query: "sw"), .search(id: 2, query: "swi")])
        #expect(state.results.isEmpty)
        #expect(state.isLoading)

        let (answered, _) = run([.searchFinished(id: 2, .success(["Swift"]))], from: state)
        #expect(answered.results == ["Swift"])
        #expect(!answered.isLoading)
    }

    @Test("A query shorter than two characters clears the results, searches for nothing, and outdates the search in flight")
    func shortQuery() {
        let (shown, _) = run([.queryChanged("sw"), .searchFinished(id: 1, .success(["Swift"]))])
        #expect(shown.results == ["Swift"])

        let (cleared, effects) = run([.queryChanged("s")], from: shown)
        #expect(effects.isEmpty)
        #expect(cleared.query == "s")
        #expect(cleared.results.isEmpty)

        let (late, _) = run([.queryChanged("sw"), .queryChanged("s"), .searchFinished(id: 1, .success(["Swift"]))])
        #expect(late.results.isEmpty)
        #expect(!late.isLoading)
        #expect(late.query == "s")
    }

    @Test("A failure shows a message and keeps the previous results on screen")
    func failureKeepsResults() {
        let (offline, _) = run([
            .queryChanged("swi"), .searchFinished(id: 1, .success(["Swift"])),
            .queryChanged("swif"), .searchFinished(id: 2, .failure(.offline)),
        ])
        #expect(offline.results == ["Swift"])
        #expect(offline.errorMessage == "You're offline.")
        #expect(!offline.isLoading)

        let (server, _) = run([.queryChanged("swi"), .searchFinished(id: 1, .failure(.server(status: 503)))])
        #expect(server.errorMessage == "Search failed (503).")
    }

    @Test("Changing the query clears an old error")
    func newQueryClearsError() {
        let (state, effects) = run([
            .queryChanged("swi"), .searchFinished(id: 1, .failure(.offline)),
            .queryChanged("swift"),
        ])
        #expect(effects.last == .search(id: 2, query: "swift"))
        #expect(state.errorMessage == nil)
        #expect(state.isLoading)
    }

    @Test("Clearing resets the screen, and a search still in flight can't bring its results back")
    func clearOutdatesInFlightSearch() {
        let (state, effects) = run([
            .queryChanged("swift"),
            .clearTapped,
            .searchFinished(id: 1, .success(["Swift"])),
            .queryChanged("kit"),
        ])
        #expect(effects == [.search(id: 1, query: "swift"), .search(id: 3, query: "kit")])
        #expect(state.query == "kit")
        #expect(state.results.isEmpty)
        #expect(state.isLoading)
    }
}
