// Kata: Log redactor (D24 · Structured logging and log shipping)
import Foundation

public enum DiagLogRedactor {
    public enum Privacy: Equatable, Sendable {
        /// Kept as is, after the safety scan for strings
        case `public`
        /// Replaced by a salted hash, so equal values can be correlated without being read
        case hashed
        /// Replaced by "<redacted>": the field existed, its value didn't leave the device
        case redacted
        /// Left out of the record entirely
        case dropped
    }

    public enum Value: Equatable, Sendable {
        case string(String)
        case int(Int)
        case bool(Bool)
    }

    public struct Field: Equatable, Sendable {
        public let key: String
        public let value: Value
        public let privacy: Privacy

        public init(_ key: String, _ value: Value, _ privacy: Privacy) {
            self.key = key
            self.value = value
            self.privacy = privacy
        }
    }

    public struct Event: Equatable, Sendable {
        public let name: String
        public let level: String
        public let fields: [Field]

        public init(name: String, level: String, fields: [Field]) {
            self.name = name
            self.level = level
            self.fields = fields
        }
    }

    public struct Policy: Equatable, Sendable {
        /// Mixed into every hash, so hashes from this app can't be looked up in someone else's table
        public var salt: String
        /// A field whose key contains any of these, ignoring case, never leaves the device
        public var deniedKeyFragments: [String]
        /// Public strings longer than this many characters are cut, ending in "…"
        public var maxStringLength: Int
        /// At most this many fields are kept; the rest are counted in "dropped_fields"
        public var maxFields: Int

        public init(salt: String, deniedKeyFragments: [String] = ["password", "token", "secret", "authorization", "cookie"], maxStringLength: Int = 120, maxFields: Int = 16) {
            self.salt = salt
            self.deniedKeyFragments = deniedKeyFragments
            self.maxStringLength = maxStringLength
            self.maxFields = maxFields
        }
    }

    /// Keys the record uses itself, which a field may not take
    public static let reservedKeys: Set<String> = ["event", "level", "dropped_fields"]
    public static let redactedText = "<redacted>"

    /// The record that may leave the device: "event", "level", one entry per kept field, and
    /// "dropped_fields" when any field was dropped for its key, as a duplicate, or by the limit
    public static func record(for event: Event, policy: Policy) -> [String: Value] {
        // Write your solution here, then run:
        // swift test --filter DiagLogRedactorTests
        return [:]
    }

    /// The record as one line of JSON, keys sorted, no spaces
    public static func jsonLine(for record: [String: Value]) -> String {
        return ""
    }
}
