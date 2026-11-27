import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct UsernameRulesTests {
    @Test("Accepts usernames that follow every rule", arguments: [
        "maneet_s",
        "a",
        "Ada2026",
        "administrator",
        "my_admin",
        "x_",
        "abcdefghijklmno",
    ])
    func accepts(username: String) {
        #expect(UsernameRules.isValid(username))
    }

    @Test("Rejects an empty username")
    func empty() {
        #expect(!UsernameRules.isValid(""))
    }

    @Test("Allows 15 characters but not 16")
    func length() {
        #expect(UsernameRules.isValid("abcdefghijklmno"))
        #expect(!UsernameRules.isValid("abcdefghijklmnop"))
        #expect(!UsernameRules.isValid(String(repeating: "z", count: 100)))
    }

    @Test("Rejects any space", arguments: ["swift dev", " leading", "trailing ", " "])
    func spaces(username: String) {
        #expect(!UsernameRules.isValid(username))
    }

    @Test("Rejects a leading underscore only")
    func underscore() {
        #expect(!UsernameRules.isValid("_hidden"))
        #expect(!UsernameRules.isValid("_"))
        #expect(UsernameRules.isValid("not_hidden"))
    }

    @Test("Rejects admin in any capitalisation", arguments: ["admin", "Admin", "ADMIN", "AdMiN", "aDMIn"])
    func reserved(username: String) {
        #expect(!UsernameRules.isValid(username))
    }

    @Test("Counts an emoji as one character")
    func emoji() {
        #expect(UsernameRules.isValid("🦊"))
        #expect(UsernameRules.isValid(String(repeating: "🦊", count: 15)))
        #expect(!UsernameRules.isValid(String(repeating: "🦊", count: 16)))
    }
}
