import DesignKit
import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A catalogue that holds every request until the test answers it, so tests decide the order in which
/// pages arrive
private actor ScriptedCatalog: PagedCatalogScreen.CatalogLoading {
    typealias Page = PagedCatalogScreen.Page

    /// The cursor of every request, in the order they were made (nil for a first page)
    private(set) var requests: [String?] = []
    private var waiting: [(cursor: String?, continuation: CheckedContinuation<Page, any Error>)] = []

    func page(after cursor: String?) async throws -> Page {
        requests.append(cursor)
        return try await withCheckedThrowingContinuation { continuation in
            waiting.append((cursor, continuation))
        }
    }

    /// Answers the oldest waiting request for `cursor`. Does nothing if there's none, so a stub that never
    /// asks fails its expectations instead of hanging.
    func answer(_ cursor: String?, with page: Page) {
        guard let index = waiting.firstIndex(where: { $0.cursor == cursor }) else { return }
        waiting.remove(at: index).continuation.resume(returning: page)
    }

    func fail(_ cursor: String?, with error: any Error) {
        guard let index = waiting.firstIndex(where: { $0.cursor == cursor }) else { return }
        waiting.remove(at: index).continuation.resume(throwing: error)
    }
}

@Suite(.timeLimit(.minutes(1))) @MainActor struct PagedCatalogScreenTests {
    typealias Screen = PagedCatalogScreen
    typealias Loaded = PagedCatalogScreen.Loaded

    private func products(_ ids: ClosedRange<Int>) -> [Screen.Product] {
        ids.map { Screen.Product(id: $0, name: "Product \($0)") }
    }

    private func page(_ ids: ClosedRange<Int>, next: String?) -> Screen.Page {
        Screen.Page(products: products(ids), nextCursor: next)
    }

    /// Runs `work` the way a view would (in its own task) and lets it reach the catalogue
    private func start(_ work: @escaping @MainActor @Sendable () async -> Void) async -> Task<Void, Never> {
        let task = Task { await work() }
        await settle()
        return task
    }

    /// A model showing products 1–3, with "p2" as the cursor for the next page
    private func loadedModel() async -> (Screen.ViewModel, ScriptedCatalog) {
        let catalog = ScriptedCatalog()
        let model = Screen.ViewModel(catalog: catalog)
        let task = await start { await model.load() }
        await catalog.answer(nil, with: page(1...3, next: "p2"))
        await task.value
        return (model, catalog)
    }

    @Test("The first load shows loading, then the first page with more to come")
    func firstLoad() async {
        let catalog = ScriptedCatalog()
        let model = Screen.ViewModel(catalog: catalog)
        #expect(model.state == .idle)

        let task = await start { await model.load() }
        #expect(model.state == .loading)
        #expect(await catalog.requests == [nil])

        await catalog.answer(nil, with: page(1...3, next: "p2"))
        await task.value
        #expect(model.state == .loaded(Loaded(products: products(1...3), footer: .more)))
    }

    @Test("A single page ends the list, and an empty one shows the empty state")
    func endAndEmpty() async {
        let catalog = ScriptedCatalog()
        let model = Screen.ViewModel(catalog: catalog)
        let task = await start { await model.load() }
        await catalog.answer(nil, with: page(1...2, next: nil))
        await task.value
        #expect(model.state == .loaded(Loaded(products: products(1...2), footer: .end)))

        await model.loadMore()
        #expect(await catalog.requests == [nil])

        let emptyCatalog = ScriptedCatalog()
        let emptyModel = Screen.ViewModel(catalog: emptyCatalog)
        let emptyTask = await start { await emptyModel.load() }
        await emptyCatalog.answer(nil, with: Screen.Page(products: [], nextCursor: nil))
        await emptyTask.value
        #expect(emptyModel.state == .empty)
    }

    @Test("A failed first load says why, and Retry loads again")
    func failureAndRetry() async {
        let catalog = ScriptedCatalog()
        let model = Screen.ViewModel(catalog: catalog)

        let first = await start { await model.load() }
        await catalog.fail(nil, with: URLError(.notConnectedToInternet))
        await first.value
        #expect(model.state == .failed(message: Screen.offlineMessage))

        let second = await start { await model.load() }
        #expect(model.state == .loading)
        await catalog.fail(nil, with: URLError(.badServerResponse))
        await second.value
        #expect(model.state == .failed(message: Screen.failureMessage))

        let third = await start { await model.load() }
        await catalog.answer(nil, with: page(1...3, next: nil))
        await third.value
        #expect(model.state == .loaded(Loaded(products: products(1...3), footer: .end)))
        #expect(await catalog.requests == [nil, nil, nil])
    }

    @Test("A cancelled first load goes back to idle, ready to load again")
    func cancelledFirstLoad() async {
        let catalog = ScriptedCatalog()
        let model = Screen.ViewModel(catalog: catalog)

        let task = await start { await model.load() }
        await catalog.fail(nil, with: CancellationError())
        await task.value
        #expect(model.state == .idle)

        let again = await start { await model.load() }
        #expect(model.state == .loading)
        await catalog.answer(nil, with: page(1...1, next: nil))
        await again.value
    }

    @Test("Loading more asks for the next cursor and appends the page")
    func loadMoreAppends() async {
        let (model, catalog) = await loadedModel()

        let task = await start { await model.loadMore() }
        #expect(model.state == .loaded(Loaded(products: products(1...3), footer: .loadingMore)))
        #expect(await catalog.requests == [nil, "p2"])

        await catalog.answer("p2", with: page(4...6, next: "p3"))
        await task.value
        #expect(model.state == .loaded(Loaded(products: products(1...6), footer: .more)))

        let last = await start { await model.loadMore() }
        await catalog.answer("p3", with: page(7...7, next: nil))
        await last.value
        #expect(model.state == .loaded(Loaded(products: products(1...7), footer: .end)))
        #expect(await catalog.requests == [nil, "p2", "p3"])
    }

    @Test("Reaching the bottom again while a page is loading asks only once")
    func loadMoreOnce() async {
        let (model, catalog) = await loadedModel()

        let task = await start { await model.loadMore() }
        await model.loadMore()
        await model.loadMore()
        #expect(await catalog.requests == [nil, "p2"])

        await catalog.answer("p2", with: page(4...4, next: nil))
        await task.value
    }

    @Test("A failed page keeps the rows, and the footer's Retry asks for the same cursor")
    func loadMoreFailure() async {
        let (model, catalog) = await loadedModel()

        let task = await start { await model.loadMore() }
        await catalog.fail("p2", with: URLError(.timedOut))
        await task.value
        #expect(model.state == .loaded(Loaded(products: products(1...3), footer: .failed(message: Screen.failureMessage))))

        let retry = await start { await model.loadMore() }
        #expect(await catalog.requests == [nil, "p2", "p2"])
        await catalog.answer("p2", with: page(4...5, next: nil))
        await retry.value
        #expect(model.state == .loaded(Loaded(products: products(1...5), footer: .end)))
    }

    @Test("Products the list already shows aren't added twice")
    func duplicatesDropped() async {
        let (model, catalog) = await loadedModel()

        let task = await start { await model.loadMore() }
        await catalog.answer("p2", with: page(3...5, next: nil))
        await task.value

        #expect(model.state == .loaded(Loaded(products: products(1...5), footer: .end)))
    }

    @Test("Refreshing keeps the rows on screen, then replaces them and starts paging again")
    func refreshReplaces() async {
        let (model, catalog) = await loadedModel()

        let task = await start { await model.refresh() }
        #expect(model.state == .loaded(Loaded(products: products(1...3), footer: .more, isRefreshing: true)))

        await catalog.answer(nil, with: page(10...11, next: "q2"))
        await task.value
        #expect(model.state == .loaded(Loaded(products: products(10...11), footer: .more)))

        let more = await start { await model.loadMore() }
        #expect(await catalog.requests == [nil, nil, "q2"])
        await catalog.answer("q2", with: page(12...12, next: nil))
        await more.value
        #expect(model.state == .loaded(Loaded(products: products(10...12), footer: .end)))
    }

    @Test("A failed refresh keeps the rows and shows a banner until the next refresh")
    func refreshFailure() async {
        let (model, catalog) = await loadedModel()

        let task = await start { await model.refresh() }
        await catalog.fail(nil, with: URLError(.notConnectedToInternet))
        await task.value
        #expect(model.state == .loaded(Loaded(products: products(1...3), footer: .more, banner: Screen.offlineMessage)))

        let again = await start { await model.refresh() }
        #expect(model.state == .loaded(Loaded(products: products(1...3), footer: .more, isRefreshing: true)))
        await catalog.answer(nil, with: Screen.Page(products: [], nextCursor: nil))
        await again.value
        #expect(model.state == .empty)
    }

    @Test("A page that arrives after a refresh started belongs to the old list and is ignored")
    func refreshDuringLoadMore() async {
        let (model, catalog) = await loadedModel()

        let more = await start { await model.loadMore() }
        let refresh = await start { await model.refresh() }
        #expect(model.state == .loaded(Loaded(products: products(1...3), footer: .more, isRefreshing: true)))

        await catalog.answer("p2", with: page(4...6, next: "p3"))
        await more.value
        #expect(model.state == .loaded(Loaded(products: products(1...3), footer: .more, isRefreshing: true)))

        await catalog.answer(nil, with: page(20...21, next: nil))
        await refresh.value
        #expect(model.state == .loaded(Loaded(products: products(20...21), footer: .end)))
    }

    @Test("Loading more waits while a refresh runs, and refreshing twice asks once")
    func busyWhileRefreshing() async {
        let (model, catalog) = await loadedModel()

        let refresh = await start { await model.refresh() }
        await model.loadMore()
        await model.refresh()
        #expect(await catalog.requests == [nil, nil])

        await catalog.answer(nil, with: page(1...3, next: "p2"))
        await refresh.value
    }

    @Test("Pulling to refresh the empty state loads again")
    func refreshFromEmpty() async {
        let catalog = ScriptedCatalog()
        let model = Screen.ViewModel(catalog: catalog)
        let first = await start { await model.load() }
        await catalog.answer(nil, with: Screen.Page(products: [], nextCursor: nil))
        await first.value
        #expect(model.state == .empty)

        let task = await start { await model.refresh() }
        #expect(model.state == .loading)
        await catalog.answer(nil, with: page(1...2, next: nil))
        await task.value
        #expect(model.state == .loaded(Loaded(products: products(1...2), footer: .end)))
    }
}
