// Generated from src/dsa/design/content/lessons/sd-solid/sd-solid-lsp.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

protocol KeyValueStore {
    func value(for key: String) -> String?
    mutating func set(_ value: String, for key: String)
}

struct MemoryStore: KeyValueStore {
    private var values: [String: String] = [:]
    func value(for key: String) -> String? { values[key] }
    mutating func set(_ value: String, for key: String) { values[key] = value }
}

// Added for guest mode: guests can't save, so set does nothing
struct GuestStore: KeyValueStore {
    func value(for key: String) -> String? { nil }
    mutating func set(_ value: String, for key: String) {}
}

func contractProblems<Store: KeyValueStore>(_ store: Store) -> [String] {
    var store = store
    var problems: [String] = []
    store.set("dark", for: "theme")
    if store.value(for: "theme") != "dark" { problems.append("a value that was set doesn't read back") }
    store.set("light", for: "theme")
    if store.value(for: "theme") != "light" { problems.append("the latest value doesn't win") }
    return problems
}

for (name, problems) in [("MemoryStore", contractProblems(MemoryStore())), ("GuestStore", contractProblems(GuestStore()))] {
    print(name + ":", problems.isEmpty ? "keeps the contract" : problems.joined(separator: "; "))
}
