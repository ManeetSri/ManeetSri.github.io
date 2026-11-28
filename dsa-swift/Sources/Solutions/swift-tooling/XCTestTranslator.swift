// Reference solution: Translating XCTest. The assertion's arguments are split at commas that sit outside
// any brackets or string literal, then rebuilt as one #expect. Each line is scanned once: O(L).

public enum XCTestTranslator {
    public static func translate(_ line: String) -> String? {
        let indent = String(line.prefix { $0 == " " })
        var body = Substring(line.dropFirst(indent.count))
        while body.last == " " {
            body.removeLast()
        }

        if body.contains("try XCTUnwrap(") {
            return indent + String(body.replacing("try XCTUnwrap(", with: "try #require("))
        }

        guard let open = body.firstIndex(of: "("), body.last == ")" else {
            return nil
        }
        let name = body[..<open]
        let inside = body[body.index(after: open)..<body.index(before: body.endIndex)]
        let arguments = splitArguments(inside)

        let needed: Int
        switch name {
        case "XCTAssertEqual", "XCTAssertNotEqual":
            needed = 2
        case "XCTAssert", "XCTAssertTrue", "XCTAssertFalse", "XCTAssertNil", "XCTAssertNotNil", "XCTAssertThrowsError":
            needed = 1
        default:
            return nil
        }
        guard arguments.count == needed || arguments.count == needed + 1 else {
            return nil
        }
        let first = arguments[0]
        let message = arguments.count > needed ? ", " + arguments[needed] : ""

        let condition: String
        switch name {
        case "XCTAssertEqual":
            condition = "\(first) == \(arguments[1])"
        case "XCTAssertNotEqual":
            condition = "\(first) != \(arguments[1])"
        case "XCTAssertFalse":
            condition = first.contains(" ") ? "!(\(first))" : "!\(first)"
        case "XCTAssertNil":
            condition = "\(first) == nil"
        case "XCTAssertNotNil":
            condition = "\(first) != nil"
        case "XCTAssertThrowsError":
            return indent + "#expect(throws: (any Error).self\(message)) { \(first) }"
        default:
            condition = first
        }
        return indent + "#expect(\(condition)\(message))"
    }

    // Splits at top-level commas: not inside (), [] or "...". Each argument is trimmed of spaces.
    private static func splitArguments(_ text: Substring) -> [String] {
        var arguments: [String] = []
        var current = ""
        var depth = 0
        var inString = false
        for character in text {
            if character == "\"" {
                inString.toggle()
            } else if !inString {
                if character == "(" || character == "[" {
                    depth += 1
                } else if character == ")" || character == "]" {
                    depth -= 1
                } else if character == "," && depth == 0 {
                    arguments.append(trimmed(current))
                    current = ""
                    continue
                }
            }
            current.append(character)
        }
        arguments.append(trimmed(current))
        return arguments
    }

    private static func trimmed(_ text: String) -> String {
        var result = Substring(text)
        while result.first == " " { result.removeFirst() }
        while result.last == " " { result.removeLast() }
        return String(result)
    }
}
