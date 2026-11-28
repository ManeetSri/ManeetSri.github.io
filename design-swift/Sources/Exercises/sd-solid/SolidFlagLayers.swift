// Kata: Layered feature flags (D04 · Liskov substitution: classes vs protocols)
import Foundation

public enum SolidFlagLayers {
    /// Anything you can read a setting from
    public protocol SettingsReader: Sendable {
        /// The value for `key`, or nil when this reader has none
        func value(for key: String) -> String?
    }

    /// A reader you can also write to. Every conforming type keeps this contract:
    /// - after `set(v, for: k)` with a non-nil `v`, `value(for: k)` returns `v`;
    /// - `set(nil, for: k)` removes this writer's own value for `k`, so `value(for: k)` returns
    ///   whatever lies underneath it, or nil if nothing does;
    /// - setting one key never changes the value of another.
    public protocol SettingsWriter: SettingsReader {
        mutating func set(_ value: String?, for key: String)
    }

    /// Values the app can't change: the defaults bundled with the app, or the last remote config
    /// fetched. Only a reader, so there's no `set` to ignore.
    public struct FixedValues: SettingsReader {
        private let values: [String: String]

        public init(_ values: [String: String]) {
            self.values = values
        }

        public func value(for key: String) -> String? {
            // Write your solution here, then run:
            // swift test --filter SolidFlagLayersTests
            return nil
        }
    }

    /// What someone sets from the debug menu: the one layer the app writes to
    public struct LocalOverrides: SettingsWriter {
        private var values: [String: String]

        public init(_ values: [String: String] = [:]) {
            self.values = values
        }

        public func value(for key: String) -> String? {
            return nil
        }

        public mutating func set(_ value: String?, for key: String) {
        }
    }

    /// Which layer a value came from, for the debug menu's "overridden" badge
    public enum Layer: Sendable, Equatable {
        case overrides
        /// The fallback at this index answered
        case fallback(Int)
    }

    /// Reads the overrides first, then each fallback in order. Writes go to the overrides only, so
    /// removing an override reveals the value underneath it.
    public struct LayeredSettings<Overrides: SettingsWriter>: SettingsWriter {
        public private(set) var overrides: Overrides
        private let fallbacks: [any SettingsReader]

        public init(overrides: Overrides, fallbacks: [any SettingsReader]) {
            self.overrides = overrides
            self.fallbacks = fallbacks
        }

        public func value(for key: String) -> String? {
            return nil
        }

        public mutating func set(_ value: String?, for key: String) {
        }

        /// The layer `value(for:)` would read `key` from, or nil when no layer has it
        public func layer(for key: String) -> Layer? {
            return nil
        }
    }

    /// Flips a flag: "on" becomes "off", and anything else (including no value) becomes "on".
    /// Written once against the contract, so it works with every writer.
    public static func toggle<Settings: SettingsWriter>(_ key: String, in settings: inout Settings) {
    }
}
