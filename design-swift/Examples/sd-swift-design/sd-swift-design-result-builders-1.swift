// Generated from src/dsa/design/content/lessons/sd-swift-design/sd-swift-design-result-builders.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Rule: Sendable {
    let message: String
    let isValid: @Sendable (String) -> Bool

    static func minLength(_ count: Int) -> Rule {
        Rule(message: "At least \(count) characters") { $0.count >= count }
    }

    static let containsDigit = Rule(message: "At least one digit") { $0.contains(where: \.isNumber) }

    static func isNot(_ word: String) -> Rule {
        Rule(message: "Can't be \"\(word)\"") { $0.lowercased() != word }
    }
}

@resultBuilder
enum RulesBuilder {
    static func buildExpression(_ rule: Rule) -> [Rule] { [rule] }
    static func buildBlock(_ parts: [Rule]...) -> [Rule] { parts.flatMap { $0 } }
    static func buildOptional(_ rules: [Rule]?) -> [Rule] { rules ?? [] }
    static func buildEither(first rules: [Rule]) -> [Rule] { rules }
    static func buildEither(second rules: [Rule]) -> [Rule] { rules }
    static func buildArray(_ rules: [[Rule]]) -> [Rule] { rules.flatMap { $0 } }
}

func problems(with password: String, @RulesBuilder rules: () -> [Rule]) -> [String] {
    rules().filter { !$0.isValid(password) }.map(\.message)
}

let isStaffAccount = true
let banned = ["password", "letmein"]

for password in ["sunny1", "Password", "correct-horse-battery-7"] {
    let found = problems(with: password) {
        Rule.minLength(8)
        Rule.containsDigit
        if isStaffAccount {
            Rule.minLength(12)
        }
        for word in banned {
            Rule.isNot(word)
        }
    }
    print(password, "→", found.isEmpty ? "OK" : found.joined(separator: "; "))
}
