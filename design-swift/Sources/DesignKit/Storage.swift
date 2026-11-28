import Foundation

/// A key–value store kept in memory: a stand-in for UserDefaults, the Keychain or a disk cache in tests
public actor InMemoryKeyValueStore {
    private var values: [String: Data] = [:]

    public init(_ values: [String: Data] = [:]) {
        self.values = values
    }

    public func data(for key: String) -> Data? { values[key] }
    public func set(_ data: Data?, for key: String) { values[key] = data }
    public var keys: [String] { values.keys.sorted() }
}

/// Collects values from any task, in the order they arrive: events, log lines, analytics calls
public actor Recorder<Value: Sendable> {
    public private(set) var values: [Value] = []

    public init() {}

    public func record(_ value: Value) {
        values.append(value)
    }
}
