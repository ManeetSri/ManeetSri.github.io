import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct DiagLogRedactorTests {
    typealias Redactor = DiagLogRedactor
    typealias Field = DiagLogRedactor.Field

    private let policy = DiagLogRedactor.Policy(salt: "s1")

    private func record(_ fields: [Field], policy: DiagLogRedactor.Policy? = nil) -> [String: DiagLogRedactor.Value] {
        Redactor.record(for: .init(name: "orders.load_failed", level: "error", fields: fields), policy: policy ?? self.policy)
    }

    @Test("The record carries the event, the level and public values unchanged")
    func publicValues() {
        let result = record([
            Field("kind", .string("unavailable"), .public),
            Field("attempts", .int(3), .public),
            Field("from_cache", .bool(false), .public),
        ])
        #expect(result == [
            "event": .string("orders.load_failed"),
            "level": .string("error"),
            "kind": .string("unavailable"),
            "attempts": .int(3),
            "from_cache": .bool(false),
        ])
    }

    @Test("Redacted fields keep their key, not their value")
    func redacted() {
        let result = record([Field("search", .string("red shoes"), .redacted), Field("postcode_digits", .int(1234), .redacted)])
        #expect(result["search"] == .string("<redacted>"))
        #expect(result["postcode_digits"] == .string("<redacted>"))
    }

    @Test("Hashed fields become a salted FNV-1a hash of their text")
    func hashed() {
        let result = record([
            Field("email", .string("maneet@example.com"), .hashed),
            Field("store", .int(42), .hashed),
            Field("member", .bool(true), .hashed),
        ])
        #expect(result["email"] == .string("h:5272c8dcde2de2f2"))
        #expect(result["store"] == .string("h:5e2b4a7ee226aa0f"))
        #expect(result["member"] == .string("h:4b4bec110ee07111"))
    }

    @Test("The same value hashes the same way; another salt hashes it differently")
    func hashCorrelation() {
        let one = record([Field("user", .string("user-881"), .hashed)])
        let again = record([Field("user", .string("user-881"), .hashed)])
        let otherSalt = record([Field("user", .string("maneet@example.com"), .hashed)], policy: .init(salt: "s2"))
        #expect(one["user"] == .string("h:6a1d903ce12d1898"))
        #expect(one == again)
        #expect(otherSalt["user"] == .string("h:26e8fb7dbcc7d501"))
    }

    @Test("Dropped fields vanish without being counted")
    func droppedQuietly() {
        let result = record([Field("debug_dump", .string("…"), .dropped), Field("kind", .string("offline"), .public)])
        #expect(result["debug_dump"] == nil)
        #expect(result["dropped_fields"] == nil)
        #expect(result["kind"] == .string("offline"))
    }

    @Test("Denied keys never leave, whatever the call site says, and are counted")
    func deniedKeys() {
        let result = record([
            Field("AuthToken", .string("eyJhbGciOi"), .public),
            Field("user_password", .string("hunter2"), .hashed),
            Field("Cookie", .string("session=1"), .redacted),
            Field("endpoint", .string("/orders"), .public),
        ])
        #expect(result["AuthToken"] == nil)
        #expect(result["user_password"] == nil)
        #expect(result["Cookie"] == nil)
        #expect(result["endpoint"] == .string("/orders"))
        #expect(result["dropped_fields"] == .int(3))
    }

    @Test("A field can't overwrite the record's own keys")
    func reservedKeys() {
        let result = record([Field("level", .string("debug"), .public), Field("event", .string("fake"), .public)])
        #expect(result["level"] == .string("error"))
        #expect(result["event"] == .string("orders.load_failed"))
        #expect(result["dropped_fields"] == .int(2))
    }

    @Test("Public strings that look personal are redacted", arguments: [
        "sent to maneet@example.com",
        "card 4111 1111 1111 1111",
        "call 07700-900-123",
        "id 123456789",
    ])
    func scanned(text: String) {
        #expect(record([Field("note", .string(text), .public)])["note"] == .string("<redacted>"))
    }

    @Test("Ordinary public strings survive the scan", arguments: [
        "order 12345678",
        "user @ home",
        "retry after 30s",
        "v5.2.0 build 812",
    ])
    func notScanned(text: String) {
        #expect(record([Field("note", .string(text), .public)])["note"] == .string(text))
    }

    @Test("Long public strings are cut to the limit, ending in an ellipsis")
    func truncation() {
        let long = String(repeating: "é", count: 130)
        let exact = String(repeating: "a", count: 120)
        let result = record([Field("body", .string(long), .public), Field("exact", .string(exact), .public)])
        #expect(result["body"] == .string(String(repeating: "é", count: 119) + "…"))
        #expect(result["exact"] == .string(exact))

        let short = record([Field("body", .string("abcdefghij"), .public)], policy: .init(salt: "s1", maxStringLength: 4))
        #expect(short["body"] == .string("abc…"))
    }

    @Test("Only the first maxFields fields are kept; the rest are counted")
    func fieldLimit() {
        let fields = (1...20).map { Field("f\($0)", .int($0), .public) }
        let result = record(fields)
        #expect(result["f16"] == .int(16))
        #expect(result["f17"] == nil)
        #expect(result["dropped_fields"] == .int(4))
        #expect(result.count == 16 + 3)        // event, level, dropped_fields
    }

    @Test("Denied keys don't use up the field limit")
    func limitAfterDenial() {
        let fields = [Field("token", .string("x"), .public)] + (1...3).map { Field("f\($0)", .int($0), .public) }
        let result = record(fields, policy: .init(salt: "s1", maxFields: 3))
        #expect(result["f3"] == .int(3))
        #expect(result["dropped_fields"] == .int(1))
    }

    @Test("When two fields share a key, the first wins and the second is counted")
    func duplicates() {
        let result = record([Field("screen", .string("basket"), .public), Field("screen", .string("checkout"), .public)])
        #expect(result["screen"] == .string("basket"))
        #expect(result["dropped_fields"] == .int(1))
    }

    @Test("The JSON line has sorted keys and no spaces")
    func jsonExact() {
        let line = Redactor.jsonLine(for: ["level": .string("info"), "ok": .bool(true), "event": .string("a.b"), "n": .int(3)])
        #expect(line == #"{"event":"a.b","level":"info","n":3,"ok":true}"#)
    }

    @Test("The JSON line escapes strings and reads back to the same record")
    func jsonRoundTrip() throws {
        let record: [String: DiagLogRedactor.Value] = [
            "event": .string("sync.failed"),
            "path": .string("/notes/42"),
            "reason": .string("said \"no\"\nthen left"),
            "count": .int(-7),
            "retried": .bool(false),
        ]
        let line = Redactor.jsonLine(for: record)
        #expect(!line.contains("\n"))
        let object = try #require(try JSONSerialization.jsonObject(with: Data(line.utf8)) as? [String: Any])
        #expect(object["reason"] as? String == "said \"no\"\nthen left")
        #expect(object["path"] as? String == "/notes/42")
        #expect(object["count"] as? Int == -7)
        #expect(object["retried"] as? Bool == false)
        #expect(object.count == 5)
    }
}
