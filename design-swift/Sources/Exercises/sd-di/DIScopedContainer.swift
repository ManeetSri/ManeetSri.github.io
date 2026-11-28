// Kata: A scoped container with cycle detection (D21 · Scopes and lifetimes)
import DesignKit

public enum DIScopedContainer {
    /// How long a registered service lives
    public enum Lifetime: Sendable {
        /// A new instance on every resolve
        case transient
        /// One instance per container that registered it: built on the first resolve, then kept for as long
        /// as that container lives
        case singleton
    }

    /// Why a resolve failed
    public enum ResolutionError: Error, Equatable, CustomStringConvertible {
        /// Nothing is registered for this type, in this container or any ancestor
        case notRegistered(String)
        /// Resolving a type led back to itself. The path names each type, from the first to the repeat.
        case cycle([String])

        public var description: String {
            switch self {
            case .notRegistered(let type): "Nothing is registered for \(type)"
            case .cycle(let path): "Dependency cycle: \(path.joined(separator: " → "))"
            }
        }
    }

    /// A registry of factories keyed by type. Use it from one place, the composition root: it isn't
    /// thread-safe, and nothing outside the root should resolve from it.
    public final class Container {
        public init() {}

        /// A container for a narrower scope, such as a signed-in session. It sees everything its parent
        /// registered, can register its own services (overriding the parent's), and keeps its own
        /// singletons only for as long as it lives.
        public func makeChild() -> Container {
            Container()
        }

        /// Registers how to build `type`. Registering a type again replaces its factory, and forgets any
        /// singleton already built from the old one.
        ///
        /// The factory receives the container to resolve dependencies from: for a transient, the container
        /// `resolve` was called on; for a singleton, the container that registered it, so an app-wide
        /// singleton can never capture a session's services.
        public func register<Service>(_ type: Service.Type, lifetime: Lifetime = .transient, factory: @escaping (Container) throws -> Service) {
            // Write your solution here, then run:
            // swift test --filter DIScopedContainerTests
        }

        /// Builds or returns the instance for `type`, looking in this container first, then its ancestors.
        /// Throws `ResolutionError.notRegistered` when no container has it, `.cycle` when building it leads
        /// back to itself, and any error a factory throws.
        public func resolve<Service>(_ type: Service.Type) throws -> Service {
            throw Unimplemented()
        }
    }
}
