// Reference solution: A generic repository. One where clause, Remote.Model == Local.Model, is the whole
// design: it lets the repository move values from the network into the store with no casts, and it
// makes pairing an Order API with a Product store a compile error. Everything else is the fetch policy.
public enum GenericRepositoryKit {
    public protocol Entity: Identifiable, Equatable, Sendable where ID: Comparable & Sendable {}

    public protocol RemoteSource<Model>: Sendable {
        associatedtype Model: Entity
        func fetchAll() async throws -> [Model]
        func fetch(id: Model.ID) async throws -> Model
    }

    public protocol LocalStore<Model>: Actor {
        associatedtype Model: Entity
        func all() -> [Model]
        func model(id: Model.ID) -> Model?
        func upsert(_ model: Model)
        func replaceAll(with models: [Model])
    }

    public actor InMemoryStore<Model: Entity>: LocalStore {
        private var byID: [Model.ID: Model] = [:]

        public init(_ models: [Model] = []) {
            for model in models {
                byID[model.id] = model
            }
        }

        public func all() -> [Model] {
            byID.values.sorted { $0.id < $1.id }
        }

        public func model(id: Model.ID) -> Model? {
            byID[id]
        }

        public func upsert(_ model: Model) {
            byID[model.id] = model
        }

        public func replaceAll(with models: [Model]) {
            byID = Dictionary(models.map { ($0.id, $0) }, uniquingKeysWith: { _, last in last })
        }
    }

    public enum FetchPolicy: Sendable {
        case cacheFirst
        case networkFirst
        case cacheOnly
    }

    public struct Repository<Remote: RemoteSource, Local: LocalStore>: Sendable where Remote.Model == Local.Model {
        public typealias Model = Remote.Model

        private let remote: Remote
        private let local: Local

        public init(remote: Remote, local: Local) {
            self.remote = remote
            self.local = local
        }

        public func items(_ policy: FetchPolicy) async throws -> [Model] {
            switch policy {
            case .cacheOnly:
                return await local.all()
            case .cacheFirst:
                let cached = await local.all()
                return cached.isEmpty ? try await refresh() : cached
            case .networkFirst:
                do {
                    return try await refresh()
                } catch {
                    let cached = await local.all()
                    if cached.isEmpty { throw error }
                    return cached
                }
            }
        }

        public func item(id: Model.ID) async throws -> Model {
            if let cached = await local.model(id: id) { return cached }
            let fresh = try await remote.fetch(id: id)
            await local.upsert(fresh)
            return fresh
        }

        // The server's list is the truth, so it replaces the cache rather than merging into it
        private func refresh() async throws -> [Model] {
            try await local.replaceAll(with: remote.fetchAll())
            return await local.all()
        }
    }
}
