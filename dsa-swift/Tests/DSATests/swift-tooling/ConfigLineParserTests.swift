import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ConfigLineParserTests {
    typealias Entry = ConfigLineParser.Entry
    typealias ParseError = ConfigLineParser.ParseError

    @Test("Parses valid lines", arguments: [
        ("name=Maneet", "name", "Maneet"),
        ("  level = 3  ", "level", "3"),
        ("max_size=100", "max_size", "100"),
        ("Theme2 =dark mode", "Theme2", "dark mode"),
        ("_hidden=yes", "_hidden", "yes"),
    ])
    func parsesValid(line: String, key: String, value: String) throws {
        #expect(try ConfigLineParser.parse(line) == Entry(key: key, value: value))
    }

    @Test("The value may be empty")
    func emptyValue() throws {
        #expect(try ConfigLineParser.parse("nickname=") == Entry(key: "nickname", value: ""))
        #expect(try ConfigLineParser.parse("nickname =   ") == Entry(key: "nickname", value: ""))
    }

    @Test("Only the first = splits the line")
    func firstEqualsOnly() throws {
        #expect(try ConfigLineParser.parse("formula=a=b+c") == Entry(key: "formula", value: "a=b+c"))
        #expect(try ConfigLineParser.parse("x==") == Entry(key: "x", value: "="))
    }

    @Test("A line without = is rejected", arguments: ["hello", "", "   ", "name: Maneet"])
    func missingEquals(line: String) {
        #expect(throws: ParseError.missingEquals) {
            try ConfigLineParser.parse(line)
        }
    }

    @Test("An empty key is rejected", arguments: ["=value", "   = value", "="])
    func emptyKey(line: String) {
        #expect(throws: ParseError.emptyKey) {
            try ConfigLineParser.parse(line)
        }
    }

    @Test("A bad key character is reported", arguments: [
        ("my key=1", Character(" ")),
        ("size-max=2", Character("-")),
        ("a.b.c=3", Character(".")),
        ("café=4", Character("é")),
    ])
    func invalidKey(line: String, bad: Character) {
        #expect(throws: ParseError.invalidKeyCharacter(bad)) {
            try ConfigLineParser.parse(line)
        }
    }

    @Test("Errors are checked in order")
    func errorOrder() {
        // No "=" beats everything else
        #expect(throws: ParseError.missingEquals) { try ConfigLineParser.parse("bad key") }
        // An empty key is reported before any character check
        #expect(throws: ParseError.emptyKey) { try ConfigLineParser.parse(" =x") }
        // The first bad character in the key is the one reported
        #expect(throws: ParseError.invalidKeyCharacter("!")) { try ConfigLineParser.parse("a!b?c=1") }
    }

    @Test("parseAll returns every entry in order")
    func parseAllValid() throws {
        let entries = try ConfigLineParser.parseAll(["a=1", "b = 2", "c="])
        #expect(entries == [Entry(key: "a", value: "1"), Entry(key: "b", value: "2"), Entry(key: "c", value: "")])
        #expect(try ConfigLineParser.parseAll([]) == [])
    }

    @Test("parseAll throws the first error")
    func parseAllThrows() {
        #expect(throws: ParseError.emptyKey) {
            try ConfigLineParser.parseAll(["a=1", "=2", "bad"])
        }
    }

    @Test("validEntries skips bad lines")
    func validEntriesSkips() {
        let entries = ConfigLineParser.validEntries(in: ["a=1", "=2", "no equals", "b c=3", "d = 4"])
        #expect(entries == [Entry(key: "a", value: "1"), Entry(key: "d", value: "4")])
        #expect(ConfigLineParser.validEntries(in: ["oops"]).isEmpty)
    }
}
