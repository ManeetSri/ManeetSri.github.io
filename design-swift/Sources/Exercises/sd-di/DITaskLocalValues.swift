// Kata: Dependency values with task-local overrides (D21 · Dependencies as values, swift-dependencies style)
public enum DITaskLocalValues {
    /// Where the code is running, which decides the default for every dependency nobody overrode
    public enum Context: Sendable {
        case live
        case preview
        case test
    }

    /// One dependency: the type of its value, and the value to use in each context
    public protocol DependencyKey {
        associatedtype Value: Sendable
        static var liveValue: Value { get }
        /// Defaults to `liveValue`
        static var previewValue: Value { get }
        static var testValue: Value { get }
    }

    /// The dependencies a piece of code sees: its context's defaults, plus whatever has been overridden.
    /// Add a dependency with a computed property in an extension that reads and writes `self[Key.self]`.
    public struct DependencyValues: Sendable {
        /// The dependencies the current task sees. Outside any `withDependencies`, that's the live context
        /// with nothing overridden.
        @TaskLocal public static var current = DependencyValues(context: .live)

        /// Which defaults to fall back on for keys that haven't been overridden
        public var context: Context

        public init(context: Context) {
            self.context = context
        }

        /// The overridden value for `key` if there is one, otherwise the default for `context`
        public subscript<Key: DependencyKey>(key: Key.Type) -> Key.Value {
            get {
                // Write your solution here, then run:
                // swift test --filter DITaskLocalValuesTests
                Key.liveValue
            }
            set {
            }
        }
    }

    /// Runs `operation` with a copy of the current dependencies changed by `update`. The change is seen by
    /// everything `operation` calls and by the tasks it creates (but not detached ones), and ends when it returns.
    public static func withDependencies<R>(_ update: (inout DependencyValues) throws -> Void, operation: () throws -> R) rethrows -> R {
        try operation()
    }

    /// The async version: `operation` may suspend, and child tasks it starts see the same values
    nonisolated(nonsending) public static func withDependencies<R>(
        _ update: (inout DependencyValues) throws -> Void,
        operation: nonisolated(nonsending) () async throws -> R
    ) async rethrows -> R {
        try await operation()
    }

    /// Reads one dependency. It captures the dependencies in force when its owner is created, so a model made
    /// inside `withDependencies` keeps using those values after the scope has ended.
    @propertyWrapper public struct Dependency<Value: Sendable>: Sendable {
        private let keyPath: KeyPath<DependencyValues, Value> & Sendable

        public init(_ keyPath: KeyPath<DependencyValues, Value> & Sendable) {
            self.keyPath = keyPath
        }

        public var wrappedValue: Value {
            DependencyValues.current[keyPath: keyPath]
        }
    }
}

extension DITaskLocalValues.DependencyKey {
    public static var previewValue: Value { liveValue }
}
