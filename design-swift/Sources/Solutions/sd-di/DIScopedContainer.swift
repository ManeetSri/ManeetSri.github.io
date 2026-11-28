// Reference solution: a scoped container. Registrations and singletons live in the container that
// registered them; lookups walk up to the parent. The types being built right now are kept on one stack,
// shared by the whole family of containers, so a factory that asks (directly or not) for a type that's
// still being built is reported as a cycle instead of recursing until the stack overflows.
public enum DIScopedContainer {
    public enum Lifetime: Sendable {
        case transient
        case singleton
    }

    public enum ResolutionError: Error, Equatable, CustomStringConvertible {
        case notRegistered(String)
        case cycle([String])

        public var description: String {
            switch self {
            case .notRegistered(let type): "Nothing is registered for \(type)"
            case .cycle(let path): "Dependency cycle: \(path.joined(separator: " → "))"
            }
        }
    }

    public final class Container {
        private struct Registration {
            let lifetime: Lifetime
            let make: (Container) throws -> Any
        }

        private let parent: Container?
        private var registrations: [ObjectIdentifier: Registration] = [:]
        private var singletons: [ObjectIdentifier: Any] = [:]
        /// The types being built right now, outermost first. Only the top container's stack is used.
        private var building: [(id: ObjectIdentifier, name: String)] = []

        public convenience init() {
            self.init(parent: nil)
        }

        private init(parent: Container?) {
            self.parent = parent
        }

        // The child holds its parent, never the other way round, so dropping a session's container
        // releases everything it built
        public func makeChild() -> Container {
            Container(parent: self)
        }

        public func register<Service>(_ type: Service.Type, lifetime: Lifetime = .transient, factory: @escaping (Container) throws -> Service) {
            let id = ObjectIdentifier(type)
            registrations[id] = Registration(lifetime: lifetime, make: { try factory($0) })
            singletons[id] = nil
        }

        public func resolve<Service>(_ type: Service.Type) throws -> Service {
            let id = ObjectIdentifier(type)
            let name = String(describing: type)
            guard let owner = registeringContainer(for: id), let registration = owner.registrations[id] else {
                throw ResolutionError.notRegistered(name)
            }
            if registration.lifetime == .singleton, let existing = owner.singletons[id] as? Service {
                return existing
            }

            // A cycle is a type that's already on the stack of things being built. A diamond (two services
            // sharing a dependency) isn't: the shared one is built and popped before the second asks for it.
            let top = topContainer
            if let start = top.building.firstIndex(where: { $0.id == id }) {
                throw ResolutionError.cycle(top.building[start...].map(\.name) + [name])
            }
            top.building.append((id, name))
            defer { top.building.removeLast() }

            let scope = registration.lifetime == .singleton ? owner : self
            guard let instance = try registration.make(scope) as? Service else {
                throw ResolutionError.notRegistered(name)
            }
            if registration.lifetime == .singleton {
                owner.singletons[id] = instance
            }
            return instance
        }

        /// The nearest container, starting with this one, that has a registration for the type
        private func registeringContainer(for id: ObjectIdentifier) -> Container? {
            var container: Container? = self
            while let current = container {
                if current.registrations[id] != nil { return current }
                container = current.parent
            }
            return nil
        }

        private var topContainer: Container {
            parent?.topContainer ?? self
        }
    }
}
