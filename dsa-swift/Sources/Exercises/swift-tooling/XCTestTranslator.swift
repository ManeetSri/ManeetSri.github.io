// Problem: Translating XCTest (M12 · Recognising XCTest)

public enum XCTestTranslator {
    /// Translates one line of an XCTest test into Swift Testing, or returns nil if the line isn't one
    /// of the forms below. Leading spaces are kept; trailing spaces are dropped.
    ///
    /// - A line containing "try XCTUnwrap(" gets every one of them replaced by "try #require(".
    /// - `XCTAssertEqual(a, b)` → `#expect(a == b)`, `XCTAssertNotEqual(a, b)` → `#expect(a != b)`
    /// - `XCTAssert(x)` and `XCTAssertTrue(x)` → `#expect(x)`
    /// - `XCTAssertFalse(x)` → `#expect(!x)`, or `#expect(!(x))` when `x` contains a space
    /// - `XCTAssertNil(x)` → `#expect(x == nil)`, `XCTAssertNotNil(x)` → `#expect(x != nil)`
    /// - `XCTAssertThrowsError(e)` → `#expect(throws: (any Error).self) { e }`
    ///
    /// Arguments are separated by commas that aren't inside brackets or a string literal, and are
    /// trimmed of spaces. Each assertion may have one extra argument, a message, which goes after the
    /// first part: `#expect(a == b, "message")`.
    public static func translate(_ line: String) -> String? {
        // Write your solution here, then run:
        // swift test --filter XCTestTranslatorTests
        return ""
    }
}
