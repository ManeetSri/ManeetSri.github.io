// Kata: A composition root for a reading app (D21 · The composition root)
import DesignKit
import Foundation

public enum DIShelfCompositionRoot {
    /// What the app reads at launch: which server, whether the user allows analytics, who's signed in
    public struct Config: Sendable {
        public enum Environment: Sendable {
            case production
            case staging
        }

        public var environment: Environment
        public var analyticsEnabled: Bool
        public var authToken: String?

        public init(environment: Environment, analyticsEnabled: Bool = true, authToken: String? = nil) {
            self.environment = environment
            self.analyticsEnabled = analyticsEnabled
            self.authToken = authToken
        }
    }

    public struct Book: Codable, Equatable, Sendable {
        public let id: String
        public let title: String

        public init(id: String, title: String) {
            self.id = id
            self.title = title
        }
    }

    /// What the library screen needs: the books on the shelf
    public protocol BookLoading: Sendable {
        func books() async throws -> [Book]
    }

    /// What every screen needs from analytics
    public protocol AnalyticsLogging: Sendable {
        func log(_ event: String) async
    }

    // MARK: - Building blocks, already written

    /// Loads the shelf with `GET <baseURL>/books`, sending the token when there is one
    public struct BookAPI: BookLoading {
        private let http: any HTTPClient
        private let baseURL: URL
        private let token: String?

        public init(http: any HTTPClient, baseURL: URL, token: String?) {
            self.http = http
            self.baseURL = baseURL
            self.token = token
        }

        public func books() async throws -> [Book] {
            var request = URLRequest(url: baseURL.appending(path: "books"))
            if let token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (data, response) = try await http.send(request)
            guard response.statusCode == 200 else { throw URLError(.badServerResponse) }
            return try JSONDecoder().decode([Book].self, from: data)
        }
    }

    /// Keeps the first successful load in memory, so every screen after the first opens instantly
    public actor CachedBooks: BookLoading {
        private let source: any BookLoading
        private var cached: [Book]?

        public init(source: any BookLoading) {
            self.source = source
        }

        public func books() async throws -> [Book] {
            if let cached { return cached }
            let books = try await source.books()
            cached = books
            return books
        }
    }

    /// Sends events in batches of three with `POST <baseURL>/events`, one event per line
    public actor BatchedAnalytics: AnalyticsLogging {
        private let http: any HTTPClient
        private let baseURL: URL
        private var pending: [String] = []

        public init(http: any HTTPClient, baseURL: URL) {
            self.http = http
            self.baseURL = baseURL
        }

        public func log(_ event: String) async {
            pending.append(event)
            guard pending.count >= 3 else { return }
            var request = URLRequest(url: baseURL.appending(path: "events"))
            request.httpMethod = "POST"
            request.httpBody = Data(pending.joined(separator: "\n").utf8)
            pending = []
            _ = try? await http.send(request)
        }
    }

    /// Analytics that goes nowhere, for people who've opted out
    public struct NoAnalytics: AnalyticsLogging {
        public init() {}
        public func log(_ event: String) async {}
    }

    @MainActor public final class LibraryModel {
        public private(set) var books: [Book] = []
        public private(set) var failed = false
        private let loader: any BookLoading
        private let analytics: any AnalyticsLogging

        public init(loader: any BookLoading, analytics: any AnalyticsLogging) {
            self.loader = loader
            self.analytics = analytics
        }

        public func load() async {
            do {
                books = try await loader.books()
                failed = false
                await analytics.log("library_viewed")
            } catch {
                failed = true
            }
        }
    }

    @MainActor public final class BookDetailModel {
        public let book: Book
        private let analytics: any AnalyticsLogging

        public init(book: Book, analytics: any AnalyticsLogging) {
            self.book = book
            self.analytics = analytics
        }

        public func open() async {
            await analytics.log("book_opened:\(book.id)")
        }
    }

    /// Replacements for the root's leaf dependencies. Anything left `nil` is the live one.
    public struct Overrides: Sendable {
        public var http: (any HTTPClient)?
        public var analytics: (any AnalyticsLogging)?

        public init(http: (any HTTPClient)? = nil, analytics: (any AnalyticsLogging)? = nil) {
            self.http = http
            self.analytics = analytics
        }
    }

    // MARK: - What you write

    /// The composition root: the only code that knows which concrete type fills each role. The app creates
    /// one at launch; tests create one with overrides. Screens get their models from its `make…` methods.
    @MainActor public final class AppRoot {
        public init(config: Config, overrides: Overrides = Overrides()) {
            // Write your solution here, then run:
            // swift test --filter DIShelfCompositionRootTests
        }

        /// `https://api.shelf.example` in production, `https://staging.api.shelf.example` on staging
        public var baseURL: URL {
            URL(string: "https://example.invalid")!
        }

        /// A new model for each library screen
        public func makeLibraryModel() -> LibraryModel {
            LibraryModel(loader: NotWired(), analytics: NoAnalytics())
        }

        /// A new model for each book screen
        public func makeBookDetailModel(for book: Book) -> BookDetailModel {
            BookDetailModel(book: book, analytics: NoAnalytics())
        }
    }

    /// A placeholder until the root is written
    private struct NotWired: BookLoading {
        func books() async throws -> [Book] {
            throw Unimplemented("AppRoot")
        }
    }
}
