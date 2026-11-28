import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Kit = GenericRepositoryKit

private struct RepoArticle: Kit.Entity {
    let id: Int
    let title: String
}

private struct RepoProduct: Kit.Entity {
    let id: String
    let pence: Int
}

private enum RepoTestError: Error, Equatable {
    case offline
    case notFound
}

/// A remote that answers from a list, can be told to fail, and counts its calls
private actor ScriptedRemote<Model: Kit.Entity>: Kit.RemoteSource {
    var models: [Model]
    var failure: RepoTestError?
    private(set) var fetchAllCalls = 0
    private(set) var fetchCalls = 0

    init(_ models: [Model], failing failure: RepoTestError? = nil) {
        self.models = models
        self.failure = failure
    }

    func fail(with error: RepoTestError?) {
        failure = error
    }

    func serve(_ models: [Model]) {
        self.models = models
    }

    func fetchAll() async throws -> [Model] {
        fetchAllCalls += 1
        if let failure { throw failure }
        return models
    }

    func fetch(id: Model.ID) async throws -> Model {
        fetchCalls += 1
        if let failure { throw failure }
        guard let model = models.first(where: { $0.id == id }) else { throw RepoTestError.notFound }
        return model
    }
}

private let articles = [
    RepoArticle(id: 3, title: "Value semantics"),
    RepoArticle(id: 1, title: "Protocols"),
    RepoArticle(id: 2, title: "Generics"),
]

@Suite struct GenericRepositoryKitTests {
    @Test("The in-memory store keeps one model per id, sorted by id")
    func inMemoryStore() async {
        let store = Kit.InMemoryStore(articles)
        #expect(await store.all().map(\.id) == [1, 2, 3])

        await store.upsert(RepoArticle(id: 2, title: "Generics, revised"))
        await store.upsert(RepoArticle(id: 0, title: "Orientation"))
        #expect(await store.all().map(\.title) == ["Orientation", "Protocols", "Generics, revised", "Value semantics"])
        #expect(await store.model(id: 3)?.title == "Value semantics")
        #expect(await store.model(id: 9) == nil)

        await store.replaceAll(with: [RepoArticle(id: 7, title: "Sendable")])
        #expect(await store.all() == [RepoArticle(id: 7, title: "Sendable")])
    }

    @Test("cacheFirst goes to the network once, then serves the cache")
    func cacheFirst() async throws {
        let remote = ScriptedRemote(articles)
        let repository = Kit.Repository(remote: remote, local: Kit.InMemoryStore<RepoArticle>())

        #expect(try await repository.items(.cacheFirst).map(\.id) == [1, 2, 3])
        await remote.serve([RepoArticle(id: 4, title: "Newer")])
        #expect(try await repository.items(.cacheFirst).map(\.id) == [1, 2, 3])
        #expect(await remote.fetchAllCalls == 1)
    }

    @Test("networkFirst always asks the network, and its list replaces the cache")
    func networkFirst() async throws {
        let remote = ScriptedRemote(articles)
        let local = Kit.InMemoryStore([RepoArticle(id: 9, title: "Deleted on the server")])
        let repository = Kit.Repository(remote: remote, local: local)

        #expect(try await repository.items(.networkFirst).map(\.id) == [1, 2, 3])
        #expect(try await repository.items(.networkFirst).map(\.id) == [1, 2, 3])
        #expect(await remote.fetchAllCalls == 2)
        #expect(await local.model(id: 9) == nil)
    }

    @Test("networkFirst falls back to the cache when the network fails")
    func networkFirstOffline() async throws {
        let remote = ScriptedRemote(articles, failing: .offline)
        let repository = Kit.Repository(remote: remote, local: Kit.InMemoryStore([articles[0]]))
        #expect(try await repository.items(.networkFirst) == [articles[0]])
    }

    @Test("With nothing cached, the network's error reaches the caller")
    func networkFirstNothingCached() async {
        let remote = ScriptedRemote(articles, failing: .offline)
        let repository = Kit.Repository(remote: remote, local: Kit.InMemoryStore<RepoArticle>())
        await #expect(throws: RepoTestError.offline) {
            try await repository.items(.networkFirst)
        }
        await #expect(throws: RepoTestError.offline) {
            try await repository.items(.cacheFirst)
        }
    }

    @Test("cacheOnly never touches the network")
    func cacheOnly() async throws {
        let remote = ScriptedRemote(articles)
        let repository = Kit.Repository(remote: remote, local: Kit.InMemoryStore([articles[1]]))
        #expect(try await repository.items(.cacheOnly) == [articles[1]])

        let empty = Kit.Repository(remote: remote, local: Kit.InMemoryStore<RepoArticle>())
        #expect(try await empty.items(.cacheOnly).isEmpty)
        #expect(await remote.fetchAllCalls == 0)
    }

    @Test("item(id:) serves a cached model without the network, and stores one it had to fetch")
    func singleItem() async throws {
        let remote = ScriptedRemote(articles)
        let local = Kit.InMemoryStore([RepoArticle(id: 1, title: "Cached copy")])
        let repository = Kit.Repository(remote: remote, local: local)

        #expect(try await repository.item(id: 1).title == "Cached copy")
        #expect(await remote.fetchCalls == 0)

        #expect(try await repository.item(id: 2).title == "Generics")
        #expect(try await repository.item(id: 2).title == "Generics")
        #expect(await remote.fetchCalls == 1)
        #expect(await local.model(id: 2) == articles[2])

        await #expect(throws: RepoTestError.notFound) {
            try await repository.item(id: 42)
        }
    }

    @Test("The same repository works for any entity, with any kind of id")
    func anyEntity() async throws {
        let products = [RepoProduct(id: "mug", pence: 900), RepoProduct(id: "lamp", pence: 2_400)]
        let repository = Kit.Repository(remote: ScriptedRemote(products), local: Kit.InMemoryStore<RepoProduct>())
        #expect(try await repository.items(.cacheFirst).map(\.id) == ["lamp", "mug"])
        #expect(try await repository.item(id: "mug").pence == 900)
    }
}
