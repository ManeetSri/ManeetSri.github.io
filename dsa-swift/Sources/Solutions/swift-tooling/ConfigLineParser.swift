// Reference solution: Parse a settings line. Find the first "=", trim both halves, then validate the key in
// the order the errors are listed. parseAll lets errors propagate with try; validEntries drops them with try?.
// O(length of the line) per line.

public enum ConfigLineParser {
    public enum ParseError: Error, Equatable {
        case missingEquals
        case emptyKey
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

    /// Removes spaces from both ends.
    private static func trimmingSpaces(_ text: Substring) -> String {
        var result = text
        while result.first == " " { result.removeFirst() }
        while result.last == " " { result.removeLast() }
        return String(result)
    }

    private static func isAllowedInKey(_ character: Character) -> Bool {
        character == "_" || (character.isASCII && (character.isLetter || character.isNumber))
    }

    public static func parse(_ line: String) throws -> Entry {
        guard let equals = line.firstIndex(of: "=") else {
            throw ParseError.missingEquals
        }
        let key = trimmingSpaces(line[..<equals])
        let value = trimmingSpaces(line[line.index(after: equals)...])
        if key.isEmpty {
            throw ParseError.emptyKey
        }
        if let bad = key.first(where: { !isAllowedInKey($0) }) {
            throw ParseError.invalidKeyCharacter(bad)
        }
        return Entry(key: key, value: value)
    }

    public static func parseAll(_ lines: [String]) throws -> [Entry] {
        var entries: [Entry] = []
        for line in lines {
            entries.append(try parse(line))   // the first error leaves the function
        }
        return entries
    }

    public static func validEntries(in lines: [String]) -> [Entry] {
        lines.compactMap { try? parse($0) }
    }
}
