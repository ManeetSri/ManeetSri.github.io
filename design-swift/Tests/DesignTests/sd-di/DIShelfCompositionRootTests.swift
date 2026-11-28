import DesignKit
import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@MainActor
@Suite struct DIShelfCompositionRootTests {
    typealias Root = DIShelfCompositionRoot.AppRoot
    typealias Config = DIShelfCompositionRoot.Config
    typealias Overrides = DIShelfCompositionRoot.Overrides
    typealias Book = DIShelfCompositionRoot.Book

    static let shelf = [Book(id: "1", title: "Middlemarch"), Book(id: "2", title: "Small Island")]

    /// A fake server: the shelf for `GET /books`, 202 for everything else
    static func server() -> StubHTTPClient {
        let body = try! JSONEncoder().encode(shelf)
        return StubHTTPClient([{ request in
            request.url?.path() == "/books" ? (body, 200) : (Data(), 202)
        }])
    }

    struct RecordingAnalytics: DIShelfCompositionRoot.AnalyticsLogging {
        let events: Recorder<String>

        func log(_ event: String) async {
            await events.record(event)
        }
    }

    private func requests(to path: String, on server: StubHTTPClient) async -> [URLRequest] {
        await server.requests.filter { $0.url?.path() == path }
    }

    @Test("Each environment talks to its own server")
    func environments() async {
        let production = Root(config: Config(environment: .production))
        #expect(production.baseURL == URL(string: "https://api.shelf.example")!)

        let server = Self.server()
        let staging = Root(config: Config(environment: .staging), overrides: Overrides(http: server))
        #expect(staging.baseURL == URL(string: "https://staging.api.shelf.example")!)
        let library = staging.makeLibraryModel()
        await library.load()
        #expect(library.books == Self.shelf)
        #expect(await server.requests.first?.url == URL(string: "https://staging.api.shelf.example/books")!)
    }

    @Test("A signed-in user's token goes with every request; a signed-out user sends none")
    func token() async {
        let signedIn = Self.server()
        let library = Root(config: Config(environment: .production, authToken: "t-42"), overrides: Overrides(http: signedIn)).makeLibraryModel()
        await library.load()
        #expect(await signedIn.requests.first?.value(forHTTPHeaderField: "Authorization") == "Bearer t-42")

        let signedOut = Self.server()
        let guestLibrary = Root(config: Config(environment: .production), overrides: Overrides(http: signedOut)).makeLibraryModel()
        await guestLibrary.load()
        #expect(guestLibrary.books == Self.shelf)
        #expect(await signedOut.requests.first?.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test("Every make call builds a new model")
    func freshModels() {
        let root = Root(config: Config(environment: .production), overrides: Overrides(http: Self.server()))
        #expect(root.makeLibraryModel() !== root.makeLibraryModel())
        #expect(root.makeBookDetailModel(for: Self.shelf[0]) !== root.makeBookDetailModel(for: Self.shelf[0]))
    }

    @Test("Every library screen shares one cache, so the shelf is fetched once")
    func sharedCache() async {
        let server = Self.server()
        let root = Root(config: Config(environment: .production), overrides: Overrides(http: server))
        let first = root.makeLibraryModel()
        await first.load()
        let second = root.makeLibraryModel()
        await second.load()
        #expect(second.books == Self.shelf)
        #expect(await requests(to: "/books", on: server).count == 1)
    }

    @Test("Swapping only the network keeps live analytics, shared by every screen, on the same network")
    func sharedAnalytics() async {
        let server = Self.server()
        let root = Root(config: Config(environment: .production), overrides: Overrides(http: server))
        let library = root.makeLibraryModel()
        await library.load()
        await root.makeBookDetailModel(for: Self.shelf[0]).open()
        await root.makeBookDetailModel(for: Self.shelf[1]).open()

        let posts = await requests(to: "/events", on: server)
        #expect(posts.count == 1)
        #expect(posts.first?.httpMethod == "POST")
        #expect(posts.first?.url == URL(string: "https://api.shelf.example/events")!)
        #expect(posts.first?.httpBody.map { String(decoding: $0, as: UTF8.self) } == "library_viewed\nbook_opened:1\nbook_opened:2")
    }

    @Test("People who opted out send no analytics")
    func optedOut() async {
        let server = Self.server()
        let root = Root(config: Config(environment: .production, analyticsEnabled: false), overrides: Overrides(http: server))
        let library = root.makeLibraryModel()
        await library.load()
        for book in Self.shelf + Self.shelf {
            await root.makeBookDetailModel(for: book).open()
        }
        #expect(library.books == Self.shelf)
        #expect(await requests(to: "/events", on: server).isEmpty)
    }

    @Test("An analytics override replaces the live analytics everywhere")
    func analyticsOverride() async {
        let server = Self.server()
        let events = Recorder<String>()
        let root = Root(config: Config(environment: .staging), overrides: Overrides(http: server, analytics: RecordingAnalytics(events: events)))
        let library = root.makeLibraryModel()
        await library.load()
        for book in Self.shelf {
            await root.makeBookDetailModel(for: book).open()
        }
        #expect(await events.values == ["library_viewed", "book_opened:1", "book_opened:2"])
        #expect(await requests(to: "/events", on: server).isEmpty)
    }
}
