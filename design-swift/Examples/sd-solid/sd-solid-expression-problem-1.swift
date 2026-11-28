// Generated from src/dsa/design/content/lessons/sd-solid/sd-solid-expression-problem.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

protocol FeedCard {
    var id: String { get }
    func height(width: Double) -> Double
}

// Added later as an operation on every card, without touching the types
extension FeedCard {
    var accessibilityLabel: String { "Feed item" }
}

struct PollCard: FeedCard {
    let id: String
    let question: String
    func height(width: Double) -> Double { 120 }
    var accessibilityLabel: String { "Poll: \(question)" }    // looks like an override
}

let poll = PollCard(id: "p1", question: "Tea or coffee?")
let feed: [any FeedCard] = [poll]
print(poll.accessibilityLabel)
print(feed[0].accessibilityLabel)
