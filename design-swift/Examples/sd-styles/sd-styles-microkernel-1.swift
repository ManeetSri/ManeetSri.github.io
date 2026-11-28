// Generated from src/dsa/design/content/lessons/sd-styles/sd-styles-microkernel.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// The contract: the only thing the core and the plug-ins share
struct FeedItem {
    let kind: String
    let fields: [String: String]
}

protocol CardPlugin {
    static var kind: String { get }
    func render(_ item: FeedItem) -> String
}

// The core: it knows the contract, never a concrete plug-in
final class CardRegistry {
    private var factories: [String: () -> any CardPlugin] = [:]
    private var made: [String: any CardPlugin] = [:]
    private let fallback: any CardPlugin

    init(fallback: any CardPlugin) {
        self.fallback = fallback
    }

    /// Register a factory, not an instance, so launch stays cheap: plug-ins are made on first use
    func register<Plugin: CardPlugin>(_ type: Plugin.Type, make: @escaping () -> Plugin) {
        precondition(factories[Plugin.kind] == nil, "Two plug-ins claim the kind \(Plugin.kind)")
        factories[Plugin.kind] = make
    }

    func render(_ item: FeedItem) -> String {
        if let plugin = made[item.kind] {
            return plugin.render(item)
        }
        guard let make = factories[item.kind] else {
            return fallback.render(item)
        }
        let plugin = make()
        made[item.kind] = plugin
        return plugin.render(item)
    }
}

// Plug-ins, each owned by a different team
struct TextCard: CardPlugin {
    static let kind = "text"
    func render(_ item: FeedItem) -> String { "Text: \(item.fields["body", default: ""])" }
}

struct PollCard: CardPlugin {
    static let kind = "poll"
    func render(_ item: FeedItem) -> String {
        let options = item.fields["options", default: ""].split(separator: "|")
        return "Poll: \(item.fields["question", default: "?"]) (\(options.count) options)"
    }
}

struct UpdateNeededCard: CardPlugin {
    static let kind = "fallback"
    func render(_ item: FeedItem) -> String { "Update the app to see this \(item.kind) post" }
}

// The composition root is the one place that knows every plug-in
let registry = CardRegistry(fallback: UpdateNeededCard())
registry.register(TextCard.self) { TextCard() }
registry.register(PollCard.self) { PollCard() }

let feed = [
    FeedItem(kind: "text", fields: ["body": "Shipping v2 today"]),
    FeedItem(kind: "poll", fields: ["question": "Tabs or spaces?", "options": "Tabs|Spaces|Both"]),
    FeedItem(kind: "live-audio", fields: ["room": "42"]),
]
for item in feed {
    print(registry.render(item))
}
