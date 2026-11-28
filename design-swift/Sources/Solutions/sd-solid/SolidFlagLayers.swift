// Reference solution: Layered feature flags. Read-only layers only promise reading, so none of them has
// a `set` that quietly does nothing. The layered type keeps the writer's whole contract, including what
// "remove" means, so it can go anywhere a writer is expected: `toggle` works on it unchanged.
import Foundation

public enum SolidFlagLayers {
    public protocol SettingsReader: Sendable {
        func value(for key: String) -> String?
    }

    public protocol SettingsWriter: SettingsReader {
        mutating func set(_ value: String?, for key: String)
    }

    public struct FixedValues: SettingsReader {
        private let values: [String: String]

        public init(_ values: [String: String]) {
            self.values = values
        }

        public func value(for key: String) -> String? {
            values[key]
        }
    }

    public struct LocalOverrides: SettingsWriter {
        private var values: [String: String]

        public init(_ values: [String: String] = [:]) {
            self.values = values
        }

        public func value(for key: String) -> String? {
            values[key]
        }

        public mutating func set(_ value: String?, for key: String) {
            values[key] = value
        }
    }

    public enum Layer: Sendable, Equatable {
        case overrides
        case fallback(Int)
    }

    public struct LayeredSettings<Overrides: SettingsWriter>: SettingsWriter {
        public private(set) var overrides: Overrides
        private let fallbacks: [any SettingsReader]

        public init(overrides: Overrides, fallbacks: [any SettingsReader]) {
            self.overrides = overrides
            self.fallbacks = fallbacks
        }

        public func value(for key: String) -> String? {
            if let value = overrides.value(for: key) { return value }
            for fallback in fallbacks {
                if let value = fallback.value(for: key) { return value }
            }
            return nil
        }

        public mutating func set(_ value: String?, for key: String) {
            overrides.set(value, for: key)
        }

        public func layer(for key: String) -> Layer? {
            if overrides.value(for: key) != nil { return .overrides }
            return fallbacks.firstIndex { $0.value(for: key) != nil }.map(Layer.fallback)
        }
    }

    public static func toggle<Settings: SettingsWriter>(_ key: String, in settings: inout Settings) {
        settings.set(settings.value(for: key) == "on" ? "off" : "on", for: key)
    }
}
