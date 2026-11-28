// Generated from src/dsa/design/content/lessons/sd-structural/sd-structural-proxy.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

@dynamicMemberLookup
struct ReadOnly<Wrapped> {
    private let wrapped: Wrapped

    init(_ wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    subscript<Value>(dynamicMember keyPath: KeyPath<Wrapped, Value>) -> Value {
        wrapped[keyPath: keyPath]
    }
}

struct Account {
    var holder: String
    var balancePence: Int
}

let account = ReadOnly(Account(holder: "Maneet", balancePence: 12_050))
print(account.holder)
print(account.balancePence)
