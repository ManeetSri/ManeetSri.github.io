import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A store that keeps one blob in memory and counts writes, standing in for a file on disk
private actor RecordingStore: DiagBreadcrumbTrail.Store {
    private(set) var data: Data?
    private(set) var writes = 0

    init(_ data: Data? = nil) {
        self.data = data
    }

    func read() async -> Data? { data }

    func write(_ data: Data) async {
        self.data = data
        writes += 1
    }

    func clear() async {
        data = nil
    }
}

@Suite struct DiagBreadcrumbTrailTests {
    typealias Trail = DiagBreadcrumbTrail.Trail
    typealias Crumb = DiagBreadcrumbTrail.Crumb
    typealias Limits = DiagBreadcrumbTrail.Limits

    private func info(_ message: String, _ category: String = "nav") -> Crumb {
        Crumb(category: category, message: message)
    }

    /// What a new launch would find in the store
    private func persisted(in store: RecordingStore) async -> [Crumb] {
        await Trail(store: store).takePreviousLaunch()
    }

    @Test("Crumbs are kept oldest first")
    func order() async {
        let trail = Trail(store: RecordingStore())
        await trail.add(info("home"))
        await trail.add(info("search"))
        await trail.add(info("product"))
        #expect(await trail.crumbs.map(\.message) == ["home", "search", "product"])
    }

    @Test("Over the count limit, the oldest crumbs go first")
    func countLimit() async {
        let trail = Trail(store: RecordingStore(), limits: Limits(maxCrumbs: 3))
        for screen in ["a", "b", "c", "d", "e"] {
            await trail.add(info(screen))
        }
        #expect(await trail.crumbs.map(\.message) == ["c", "d", "e"])
    }

    @Test("Over the byte budget, the oldest crumbs go first")
    func byteBudget() async {
        let trail = Trail(store: RecordingStore(), limits: Limits(maxBytes: 20))
        // Each costs 3 ("net") + 5 = 8 bytes: three would be 24
        for path in ["/feed", "/cart", "/user"] {
            await trail.add(info(path, "net"))
        }
        #expect(await trail.crumbs.map(\.message) == ["/cart", "/user"])
    }

    @Test("A crumb bigger than the whole budget is trimmed from the end of its message")
    func oversized() async {
        let trail = Trail(store: RecordingStore(), limits: Limits(maxBytes: 10))
        await trail.add(info("abcdefghijkl", "net"))
        #expect(await trail.crumbs == [info("abcdefg", "net")])
    }

    @Test("Trimming never splits a character")
    func trimsWholeCharacters() async {
        let trail = Trail(store: RecordingStore(), limits: Limits(maxBytes: 7))
        // "ui" is 2 bytes and each "é" is 2, so two of them fit in 7
        await trail.add(info("ééééé", "ui"))
        #expect(await trail.crumbs == [info("éé", "ui")])
    }

    @Test("A trimmed crumb pushes everything older out")
    func oversizedEvictsOthers() async {
        let trail = Trail(store: RecordingStore(), limits: Limits(maxBytes: 10))
        await trail.add(info("x", "a"))
        await trail.add(info("abcdefghijkl", "net"))
        #expect(await trail.crumbs == [info("abcdefg", "net")])
    }

    @Test("Info crumbs are written in batches")
    func batches() async {
        let store = RecordingStore()
        let trail = Trail(store: store, limits: Limits(persistEvery: 3))
        await trail.add(info("a"))
        await trail.add(info("b"))
        #expect(await store.writes == 0)
        await trail.add(info("c"))
        #expect(await store.writes == 1)
        for message in ["d", "e", "f"] {
            await trail.add(info(message))
        }
        #expect(await store.writes == 2)
        #expect(await persisted(in: store).map(\.message) == ["a", "b", "c", "d", "e", "f"])
    }

    @Test("Warnings and errors are written at once, with the crumbs before them", arguments: [DiagBreadcrumbTrail.Level.warning, .error])
    func importantWriteThrough(level: DiagBreadcrumbTrail.Level) async {
        let store = RecordingStore()
        let trail = Trail(store: store, limits: Limits(persistEvery: 10))
        await trail.add(info("checkout"))
        #expect(await store.writes == 0)
        await trail.add(Crumb(category: "error", message: "orders.unavailable", level: level))
        #expect(await store.writes == 1)
        #expect(await persisted(in: store) == [info("checkout"), Crumb(category: "error", message: "orders.unavailable", level: level)])
    }

    @Test("Any write starts the batch count again")
    func batchCountResets() async {
        let store = RecordingStore()
        let trail = Trail(store: store, limits: Limits(persistEvery: 2))
        await trail.add(info("a"))
        await trail.add(Crumb(category: "net", message: "503", level: .warning))
        await trail.add(info("b"))
        #expect(await store.writes == 1)
        await trail.add(info("c"))
        #expect(await store.writes == 2)
    }

    @Test("flush writes the trail now")
    func flush() async {
        let store = RecordingStore()
        let trail = Trail(store: store)
        await trail.add(info("settings"))
        await trail.flush()
        #expect(await store.writes == 1)
        #expect(await persisted(in: store) == [info("settings")])
    }

    @Test("What's persisted is the trimmed trail, not every crumb ever added")
    func persistsWithinBudget() async {
        let store = RecordingStore()
        let trail = Trail(store: store, limits: Limits(maxCrumbs: 2))
        for screen in ["a", "b", "c"] {
            await trail.add(info(screen))
        }
        await trail.flush()
        #expect(await persisted(in: store).map(\.message) == ["b", "c"])
    }

    @Test("The next launch reads the previous trail once")
    func previousLaunch() async {
        let store = RecordingStore()
        let crashed = Trail(store: store)
        await crashed.add(info("basket"))
        await crashed.add(Crumb(category: "lifecycle", message: "memory warning", level: .warning))

        let next = Trail(store: store)
        #expect(await next.takePreviousLaunch() == [info("basket"), Crumb(category: "lifecycle", message: "memory warning", level: .warning)])
        #expect(await next.takePreviousLaunch() == [])
        #expect(await store.data == nil)
        #expect(await next.crumbs.isEmpty)
    }

    @Test("Unreadable data gives an empty trail, and is cleared")
    func corrupt() async {
        let store = RecordingStore(Data("not a trail".utf8))
        #expect(await Trail(store: store).takePreviousLaunch() == [])
        #expect(await store.data == nil)
    }

    @Test("A first launch has no previous trail")
    func nothingStored() async {
        #expect(await Trail(store: RecordingStore()).takePreviousLaunch() == [])
    }
}
