import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct DIScopedContainerTests {
    typealias Container = DIScopedContainer.Container
    typealias ResolutionError = DIScopedContainer.ResolutionError

    protocol Logging: AnyObject {
        func log(_ line: String)
    }

    final class ConsoleLog: Logging {
        func log(_ line: String) {}
    }

    final class APIClient {}

    final class Analytics {
        let api: APIClient
        init(api: APIClient) { self.api = api }
    }

    final class SessionStore {
        let user: String
        init(user: String) { self.user = user }
    }

    final class CartModel {
        let session: SessionStore
        init(session: SessionStore) { self.session = session }
    }

    /// An app-wide service that would leak the signed-in user if it captured the session
    final class PushRegistrar {
        let session: SessionStore
        init(session: SessionStore) { self.session = session }
    }

    struct Greeting {
        let text: String
    }

    final class Checkout {
        init(payments: Payments) {}
    }

    final class Payments {
        init(checkout: Checkout) {}
    }

    final class Feed {
        init(feed: Feed) {}
    }

    final class Library {
        let books: BookStore
        let search: SearchIndex
        init(books: BookStore, search: SearchIndex) {
            self.books = books
            self.search = search
        }
    }

    final class BookStore {
        let database: Database
        init(database: Database) { self.database = database }
    }

    final class SearchIndex {
        let database: Database
        init(database: Database) { self.database = database }
    }

    final class Database {}

    struct TokenMissing: Error {}

    @Test("A transient service is built afresh on every resolve")
    func transient() throws {
        let container = Container()
        container.register(APIClient.self) { _ in APIClient() }
        let first = try container.resolve(APIClient.self)
        let second = try container.resolve(APIClient.self)
        #expect(first !== second)
    }

    @Test("A singleton is built once, on its first resolve, and then shared")
    func singleton() throws {
        let container = Container()
        var builds = 0
        container.register(APIClient.self, lifetime: .singleton) { _ in
            builds += 1
            return APIClient()
        }
        #expect(builds == 0)
        let first = try container.resolve(APIClient.self)
        let second = try container.resolve(APIClient.self)
        #expect(first === second)
        #expect(builds == 1)
    }

    @Test("Factories resolve their own dependencies, and protocols work as keys")
    func dependencies() throws {
        let container = Container()
        container.register(APIClient.self, lifetime: .singleton) { _ in APIClient() }
        container.register(Analytics.self) { try Analytics(api: $0.resolve(APIClient.self)) }
        container.register((any Logging).self, lifetime: .singleton) { _ in ConsoleLog() }
        let analytics = try container.resolve(Analytics.self)
        let api = try container.resolve(APIClient.self)
        #expect(analytics.api === api)
        let log = try container.resolve((any Logging).self)
        #expect(log is ConsoleLog)
    }

    @Test("Resolving something nobody registered names the missing type")
    func notRegistered() {
        let container = Container()
        container.register(Analytics.self) { try Analytics(api: $0.resolve(APIClient.self)) }
        #expect(throws: ResolutionError.notRegistered("APIClient")) {
            try container.resolve(Analytics.self)
        }
        #expect(throws: ResolutionError.notRegistered("Greeting")) {
            try container.resolve(Greeting.self)
        }
    }

    @Test("Registering again replaces the factory and forgets the singleton built from the old one")
    func reRegister() throws {
        let container = Container()
        container.register(Greeting.self, lifetime: .singleton) { _ in Greeting(text: "live") }
        #expect(try container.resolve(Greeting.self).text == "live")
        container.register(Greeting.self, lifetime: .singleton) { _ in Greeting(text: "fake") }
        #expect(try container.resolve(Greeting.self).text == "fake")
    }

    @Test("A factory's error reaches the caller, and a failed singleton is tried again next time")
    func factoryErrors() throws {
        let container = Container()
        var hasToken = false
        container.register(SessionStore.self, lifetime: .singleton) { _ in
            guard hasToken else { throw TokenMissing() }
            return SessionStore(user: "ana")
        }
        #expect(throws: TokenMissing.self) {
            try container.resolve(SessionStore.self)
        }
        hasToken = true
        #expect(try container.resolve(SessionStore.self).user == "ana")
    }

    @Test("A cycle is reported with its path, instead of recursing for ever")
    func cycle() {
        let container = Container()
        container.register(Checkout.self) { try Checkout(payments: $0.resolve(Payments.self)) }
        container.register(Payments.self, lifetime: .singleton) { try Payments(checkout: $0.resolve(Checkout.self)) }
        container.register(Feed.self) { try Feed(feed: $0.resolve(Feed.self)) }
        #expect(throws: ResolutionError.cycle(["Checkout", "Payments", "Checkout"])) {
            try container.resolve(Checkout.self)
        }
        #expect(throws: ResolutionError.cycle(["Payments", "Checkout", "Payments"])) {
            try container.resolve(Payments.self)
        }
        #expect(throws: ResolutionError.cycle(["Feed", "Feed"])) {
            try container.resolve(Feed.self)
        }
    }

    @Test("A shared dependency is a diamond, not a cycle, and a failed resolve leaves the container usable")
    func diamond() throws {
        let container = Container()
        container.register(Database.self, lifetime: .singleton) { _ in Database() }
        container.register(BookStore.self) { try BookStore(database: $0.resolve(Database.self)) }
        container.register(SearchIndex.self) { try SearchIndex(database: $0.resolve(Database.self)) }
        container.register(Library.self) { try Library(books: $0.resolve(BookStore.self), search: $0.resolve(SearchIndex.self)) }
        container.register(Feed.self) { try Feed(feed: $0.resolve(Feed.self)) }
        #expect(throws: ResolutionError.cycle(["Feed", "Feed"])) {
            try container.resolve(Feed.self)
        }
        let library = try container.resolve(Library.self)
        #expect(library.books.database === library.search.database)
    }

    @Test("A child sees its parent's registrations and can override them for itself only")
    func childOverrides() throws {
        let app = Container()
        app.register(Greeting.self) { _ in Greeting(text: "app") }
        let session = app.makeChild()
        #expect(try session.resolve(Greeting.self).text == "app")
        session.register(Greeting.self) { _ in Greeting(text: "session") }
        #expect(try session.resolve(Greeting.self).text == "session")
        #expect(try app.resolve(Greeting.self).text == "app")
    }

    @Test("A parent's singleton is shared with every child")
    func parentSingletonShared() throws {
        let app = Container()
        app.register(APIClient.self, lifetime: .singleton) { _ in APIClient() }
        let first = try app.makeChild().resolve(APIClient.self)
        let second = try app.makeChild().resolve(APIClient.self)
        let own = try app.resolve(APIClient.self)
        #expect(first === second)
        #expect(first === own)
    }

    @Test("Each session keeps its own singletons, and releases them when it ends")
    func sessionScope() throws {
        let app = Container()
        var session: Container? = app.makeChild()
        session?.register(SessionStore.self, lifetime: .singleton) { _ in SessionStore(user: "ana") }
        let other = app.makeChild()
        other.register(SessionStore.self, lifetime: .singleton) { _ in SessionStore(user: "ben") }

        weak let store: SessionStore? = try session?.resolve(SessionStore.self)
        #expect(store?.user == "ana")
        #expect(store === (try session?.resolve(SessionStore.self)))
        #expect(try other.resolve(SessionStore.self).user == "ben")
        #expect(throws: ResolutionError.notRegistered("SessionStore")) {
            try app.resolve(SessionStore.self)
        }

        session = nil
        #expect(store == nil)
    }

    @Test("A transient the app registers is built in the scope that asks for it")
    func transientUsesCallerScope() throws {
        let app = Container()
        app.register(CartModel.self) { try CartModel(session: $0.resolve(SessionStore.self)) }
        let session = app.makeChild()
        session.register(SessionStore.self, lifetime: .singleton) { _ in SessionStore(user: "ana") }
        #expect(try session.resolve(CartModel.self).session.user == "ana")
        #expect(throws: ResolutionError.notRegistered("SessionStore")) {
            try app.resolve(CartModel.self)
        }
    }

    @Test("A parent's singleton is built from the parent, so it can't capture a session's services")
    func noCaptiveDependencies() {
        let app = Container()
        app.register(PushRegistrar.self, lifetime: .singleton) { try PushRegistrar(session: $0.resolve(SessionStore.self)) }
        let session = app.makeChild()
        session.register(SessionStore.self, lifetime: .singleton) { _ in SessionStore(user: "ana") }
        #expect(throws: ResolutionError.notRegistered("SessionStore")) {
            try session.resolve(PushRegistrar.self)
        }
    }
}
