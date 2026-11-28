// Generated from src/dsa/design/content/lessons/sd-functional/sd-functional-core-shell.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct ReviewHistory: Codable, Equatable {
    var completedOrders = 0
    var lastPrompt: Date?
    var lastPromptVersion: String?
}

enum ReviewDecision: Equatable {
    case ask
    case tooFewOrders
    case alreadyAskedInThisVersion
    case askedRecently
}

enum ReviewPolicy {
    static let minimumOrders = 3
    static let minimumGap: TimeInterval = 120 * 86_400   // 120 days

    /// Records a completed order and decides whether this is a good moment to ask for a review
    static func afterOrder(_ history: ReviewHistory, now: Date, appVersion: String) -> (ReviewHistory, ReviewDecision) {
        var history = history
        history.completedOrders += 1
        let decision = decide(history, now: now, appVersion: appVersion)
        if decision == .ask {
            history.lastPrompt = now
            history.lastPromptVersion = appVersion
        }
        return (history, decision)
    }

    static func decide(_ history: ReviewHistory, now: Date, appVersion: String) -> ReviewDecision {
        if history.completedOrders < minimumOrders { return .tooFewOrders }
        if history.lastPromptVersion == appVersion { return .alreadyAskedInThisVersion }
        if let last = history.lastPrompt, now.timeIntervalSince(last) < minimumGap { return .askedRecently }
        return .ask
    }
}

// Seven orders over five months, across three app versions
let start = Date(timeIntervalSince1970: 1_750_000_000)
var history = ReviewHistory()
for (day, version) in [(0, "2.3"), (1, "2.3"), (2, "2.3"), (9, "2.3"), (40, "2.4"), (130, "2.4"), (131, "2.5")] {
    let now = start.addingTimeInterval(Double(day) * 86_400)
    let (updated, decision) = ReviewPolicy.afterOrder(history, now: now, appVersion: version)
    history = updated
    print("Day \(day), v\(version), order \(history.completedOrders): \(decision)")
}
