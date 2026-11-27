import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct XCTestTranslatorTests {
    @Test("Each assertion becomes one #expect", arguments: [
        ("XCTAssertEqual(total, 7)", "#expect(total == 7)"),
        ("XCTAssertNotEqual(first, last)", "#expect(first != last)"),
        ("XCTAssertTrue(list.isEmpty)", "#expect(list.isEmpty)"),
        ("XCTAssert(isSorted)", "#expect(isSorted)"),
        ("XCTAssertFalse(list.isEmpty)", "#expect(!list.isEmpty)"),
        ("XCTAssertNil(secondLargest(in: [3]))", "#expect(secondLargest(in: [3]) == nil)"),
        ("XCTAssertNotNil(index)", "#expect(index != nil)"),
        ("XCTAssertThrowsError(try parse(line))", "#expect(throws: (any Error).self) { try parse(line) }"),
    ])
    func basics(line: String, expected: String) {
        #expect(XCTestTranslator.translate(line) == expected)
    }

    @Test("XCTAssertFalse wraps a condition that contains spaces", arguments: [
        ("XCTAssertFalse(a < b)", "#expect(!(a < b))"),
        ("XCTAssertFalse(contains(items, 3))", "#expect(!(contains(items, 3)))"),
        ("XCTAssertFalse(done)", "#expect(!done)"),
    ])
    func negation(line: String, expected: String) {
        #expect(XCTestTranslator.translate(line) == expected)
    }

    @Test("Commas inside brackets or strings don't split arguments", arguments: [
        ("XCTAssertEqual(max(a, b), 9)", "#expect(max(a, b) == 9)"),
        ("XCTAssertEqual(sorted([3, 1, 2]), [1, 2, 3])", "#expect(sorted([3, 1, 2]) == [1, 2, 3])"),
        ("XCTAssertEqual(name, \"Smith, Jo\")", "#expect(name == \"Smith, Jo\")"),
        ("XCTAssertTrue(words.contains(\"a)b\"))", "#expect(words.contains(\"a)b\"))"),
    ])
    func nestedCommas(line: String, expected: String) {
        #expect(XCTestTranslator.translate(line) == expected)
    }

    @Test("A message argument is kept as the last argument", arguments: [
        ("XCTAssertEqual(total, 7, \"total is wrong\")", "#expect(total == 7, \"total is wrong\")"),
        ("XCTAssertTrue(ok, \"should be ok, really\")", "#expect(ok, \"should be ok, really\")"),
        ("XCTAssertNil(error, \"no error\")", "#expect(error == nil, \"no error\")"),
        ("XCTAssertThrowsError(try load(), \"must throw\")", "#expect(throws: (any Error).self, \"must throw\") { try load() }"),
    ])
    func messages(line: String, expected: String) {
        #expect(XCTestTranslator.translate(line) == expected)
    }

    @Test("XCTUnwrap becomes #require wherever it appears", arguments: [
        ("let first = try XCTUnwrap(sample.first)", "let first = try #require(sample.first)"),
        ("XCTAssertEqual(try XCTUnwrap(value), 3)", "XCTAssertEqual(try #require(value), 3)"),
    ])
    func unwrap(line: String, expected: String) {
        #expect(XCTestTranslator.translate(line) == expected)
    }

    @Test("Indentation is kept and trailing spaces are dropped")
    func indentation() {
        #expect(XCTestTranslator.translate("        XCTAssertEqual(a, b)") == "        #expect(a == b)")
        #expect(XCTestTranslator.translate("    XCTAssertNil(x)   ") == "    #expect(x == nil)")
        #expect(XCTestTranslator.translate("  let v = try XCTUnwrap(w)  ") == "  let v = try #require(w)")
    }

    @Test("Spaces around arguments are tidied")
    func argumentSpaces() {
        #expect(XCTestTranslator.translate("XCTAssertEqual( a ,b )") == "#expect(a == b)")
    }

    @Test("Anything else isn't an assertion we know", arguments: [
        "let x = 5",
        "",
        "XCTFail(\"not done\")",
        "XCTAssertEqual(a)",
        "XCTAssertEqual(a, b, \"m\", extra)",
        "XCTAssertTrue(a, \"m\", extra)",
        "XCTAssertNil",
        "XCTAssertGreaterThan(a, b)",
        "print(XCTAssertTrue(x))",
        "#expect(a == b)",
    ])
    func unknown(line: String) {
        #expect(XCTestTranslator.translate(line) == nil)
    }
}
