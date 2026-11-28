// Reference solution: Log redactor. Filter first (denied and reserved keys, explicit drops, duplicates,
// the field limit), then transform each kept value by its declared privacy, scanning public strings
// as a last line of defence. Everything is a pure function of the event and the policy.
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
        public var salt: String
        public var deniedKeyFragments: [String]
        public var maxStringLength: Int
        public var maxFields: Int

        public init(salt: String, deniedKeyFragments: [String] = ["password", "token", "secret", "authorization", "cookie"], maxStringLength: Int = 120, maxFields: Int = 16) {
            self.salt = salt
            self.deniedKeyFragments = deniedKeyFragments
            self.maxStringLength = maxStringLength
            self.maxFields = maxFields
        }
    }

    public static let reservedKeys: Set<String> = ["event", "level", "dropped_fields"]
    public static let redactedText = "<redacted>"

    public static func record(for event: Event, policy: Policy) -> [String: Value] {
        var dropped = 0
        var seen = Set<String>()
        var kept: [Field] = []
        let fragments = policy.deniedKeyFragments.map { $0.lowercased() }

        for field in event.fields {
            let key = field.key.lowercased()
            if fragments.contains(where: { key.contains($0) }) || reservedKeys.contains(field.key) {
                dropped += 1                    // dangerous or clashing: never leaves, but we count it
            } else if field.privacy == .dropped {
                continue                        // the call site asked for it: not counted
            } else if seen.contains(field.key) {
                dropped += 1                    // the first field with a key wins
            } else if kept.count == policy.maxFields {
                dropped += 1                    // over the size budget
            } else {
                seen.insert(field.key)
                kept.append(field)
            }
        }

        var record: [String: Value] = ["event": .string(event.name), "level": .string(event.level)]
        for field in kept {
            record[field.key] = redact(field, policy: policy)
        }
        if dropped > 0 { record["dropped_fields"] = .int(dropped) }
        return record
    }

    public static func jsonLine(for record: [String: Value]) -> String {
        let object: [String: Any] = record.mapValues { value -> Any in
            switch value {
            case .string(let text): text
            case .int(let number): number
            case .bool(let flag): flag
            }
        }
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys, .withoutEscapingSlashes]) else { return "{}" }
        return String(decoding: data, as: UTF8.self)
    }

    private static func redact(_ field: Field, policy: Policy) -> Value {
        switch field.privacy {
        case .redacted, .dropped:
            return .string(redactedText)
        case .hashed:
            return .string(hashed(text(of: field.value), salt: policy.salt))
        case .public:
            guard case .string(let text) = field.value else { return field.value }
            if looksPersonal(text) { return .string(redactedText) }
            return .string(truncated(text, to: policy.maxStringLength))
        }
    }

    private static func text(of value: Value) -> String {
        switch value {
        case .string(let text): text
        case .int(let number): String(number)
        case .bool(let flag): flag ? "true" : "false"
        }
    }

    /// An email address, or nine or more digits (single spaces or dashes allowed between them)
    private static func looksPersonal(_ text: String) -> Bool {
        text.contains(/[^\s@]+@[^\s@]+\.[^\s@]+/) || text.contains(/[0-9](?:[ -]?[0-9]){8,}/)
    }

    private static func truncated(_ text: String, to limit: Int) -> String {
        guard text.count > limit else { return text }
        return String(text.prefix(max(0, limit - 1))) + "…"
    }

    /// "h:" and the 64-bit FNV-1a hash of salt, ":" and the value, as 16 lowercase hex digits
    private static func hashed(_ text: String, salt: String) -> String {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in "\(salt):\(text)".utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x0000_0100_0000_01b3
        }
        let hex = String(hash, radix: 16)
        return "h:" + String(repeating: "0", count: 16 - hex.count) + hex
    }
}
