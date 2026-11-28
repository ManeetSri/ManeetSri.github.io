// Reference solution: dependency values in a task local. The values are a struct (so every scope works on its
// own copy) holding only the overrides; anything not overridden falls back to the context's default.
// `withDependencies` binds a changed copy for the length of an operation, which Swift's task locals hand on
// to child tasks for free. The property wrapper snapshots the values when its owner is created.
public enum DITaskLocalValues {
    public enum Context: Sendable {
        case live
        case preview
        case test
    }

    public protocol DependencyKey {
        associatedtype Value: Sendable
        static var liveValue: Value { get }
        static var previewValue: Value { get }
        static var testValue: Value { get }
    }

    public struct DependencyValues: Sendable {
        @TaskLocal public static var current = DependencyValues(context: .live)

        public var context: Context
        private var overrides: [ObjectIdentifier: any Sendable] = [:]

        public init(context: Context) {
            self.context = context
        }

        public subscript<Key: DependencyKey>(key: Key.Type) -> Key.Value {
            get {
                if let value = overrides[ObjectIdentifier(key)] as? Key.Value {
                    return value
                }
                switch context {
                case .live: return Key.liveValue
                case .preview: return Key.previewValue
                case .test: return Key.testValue
                }
            }
            set {
                overrides[ObjectIdentifier(key)] = newValue
            }
        }
    }

    public static func withDependencies<R>(_ update: (inout DependencyValues) throws -> Void, operation: () throws -> R) rethrows -> R {
        var values = DependencyValues.current
        try update(&values)
        return try DependencyValues.$current.withValue(values, operation: operation)
    }

    nonisolated(nonsending) public static func withDependencies<R>(
        _ update: (inout DependencyValues) throws -> Void,
        operation: nonisolated(nonsending) () async throws -> R
    ) async rethrows -> R {
        var values = DependencyValues.current
        try update(&values)
        return try await DependencyValues.$current.withValue(values, operation: operation)
    }

    @propertyWrapper public struct Dependency<Value: Sendable>: Sendable {
        private let keyPath: KeyPath<DependencyValues, Value> & Sendable
        private let captured: DependencyValues

        public init(_ keyPath: KeyPath<DependencyValues, Value> & Sendable) {
            self.keyPath = keyPath
            self.captured = DependencyValues.current
        }

        public var wrappedValue: Value {
            captured[keyPath: keyPath]
        }
    }
}

extension DITaskLocalValues.DependencyKey {
    public static var previewValue: Value { liveValue }
}
