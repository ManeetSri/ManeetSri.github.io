// Problem: Parse a settings line (M12 · throws, try and Result)

public enum ConfigLineParser {
    public enum ParseError: Error, Equatable {
        /// The line has no "=" at all.
        case missingEquals
        /// There's nothing but spaces before the first "=".
        case emptyKey
        /// The key contains this character, which isn't an ASCII letter, digit or "_".
        case invalidKeyCharacter(Character)
    }

    public struct Entry: Equatable {
        public let key: String
        public let value: String

        public init(key: String, value: String) {
            self.key = key
            self.value = value
        }
    }

    /// Splits `line` at its first "=" into a key and a value, each with surrounding spaces removed,
    /// or throws the first problem found, checked in the order the cases are listed.
    public static func parse(_ line: String) throws -> Entry {
        // Write your solution here, then run:
        // swift test --filter ConfigLineParserTests
        return Entry(key: "", value: "")
    }

    /// Parses every line, in order, or throws the first error any line causes.
    public static func parseAll(_ lines: [String]) throws -> [Entry] {
        return []
    }

    /// Parses every line, in order, silently skipping lines that cause an error.
    public static func validEntries(in lines: [String]) -> [Entry] {
        return []
    }
}
