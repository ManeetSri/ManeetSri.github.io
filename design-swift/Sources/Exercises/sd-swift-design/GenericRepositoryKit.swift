// Kata: A generic repository (D06 · Generics and associated types as design tools)
import DesignKit

public enum GenericRepositoryKit {
    /// Something the app stores and fetches by id. Ids are Comparable, so lists come back in a stable order.
    public protocol Entity: Identifiable, Equatable, Sendable where ID: Comparable & Sendable {}

    /// Where fresh models come from: usually an API client
    public protocol RemoteSource<Model>: Sendable {
        associatedtype Model: Entity
        func fetchAll() async throws -> [Model]
        func fetch(id: Model.ID) async throws -> Model
    }

    /// Where models are kept on the device. An actor, so the repository can share it safely.
    public protocol LocalStore<Model>: Actor {
        associatedtype Model: Entity
        /// Every model, sorted by id
        func all() -> [Model]
        func model(id: Model.ID) -> Model?
        /// Inserts the model, or replaces the one with the same id
        func upsert(_ model: Model)
        /// Makes the store hold exactly these models
        func replaceAll(with models: [Model])
    }

    /// A LocalStore kept in memory: the store the tests use, and a fine cache for small lists
    public actor InMemoryStore<Model: Entity>: LocalStore {
        public init(_ models: [Model] = []) {
            // Write your solution here, then run:
            // swift test --filter GenericRepositoryKitTests
        }

        public func all() -> [Model] {
            []
        }

        public func model(id: Model.ID) -> Model? {
            nil
        }

        public func upsert(_ model: Model) {}

        public func replaceAll(with models: [Model]) {}
    }

    public enum FetchPolicy: Sendable {
        /// The cached list if there is one, otherwise the network
        case cacheFirst
        /// The network, falling back to the cached list when it fails
        case networkFirst
        /// Only the cache; never touches the network
        case cacheOnly
    }

    /// Joins a remote source and a local store that hold the same kind of model
    public struct Repository<Remote: RemoteSource, Local: LocalStore>: Sendable where Remote.Model == Local.Model {
        public typealias Model = Remote.Model

        public init(remote: Remote, local: Local) {}

        /// The whole list, following `policy`. A list from the network replaces what the store held.
        public func items(_ policy: FetchPolicy) async throws -> [Model] {
            throw Unimplemented()
        }

        /// One model: from the store if it's there, otherwise fetched and then stored
        public func item(id: Model.ID) async throws -> Model {
            throw Unimplemented()
        }
    }
}
