// Generated from src/dsa/design/content/lessons/sd-solid/sd-solid-ocp.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct AnalyticsEvent {
    let name: String
    let properties: [String: String]
}

protocol AnalyticsDestination {
    func send(_ event: AnalyticsEvent)
}

// Closed: written and tested once, and it never learns about a vendor
struct AnalyticsTracker {
    let destinations: [any AnalyticsDestination]

    func track(_ name: String, _ properties: [String: String] = [:]) {
        let event = AnalyticsEvent(name: name, properties: properties)
        destinations.forEach { $0.send(event) }
    }
}

struct ConsoleDestination: AnalyticsDestination {
    let prefix: String
    func send(_ event: AnalyticsEvent) { print("\(prefix): \(event.name)") }
}

// Added months later for a privacy review, without editing the tracker:
// it wraps another destination and drops events that carry personal data
struct PrivacyFilter: AnalyticsDestination {
    let wrapped: any AnalyticsDestination
    let blockedKeys: Set<String>

    func send(_ event: AnalyticsEvent) {
        guard blockedKeys.isDisjoint(with: event.properties.keys) else {
            print("filtered: \(event.name)")
            return
        }
        wrapped.send(event)
    }
}

let tracker = AnalyticsTracker(destinations: [
    ConsoleDestination(prefix: "debug log"),
    PrivacyFilter(wrapped: ConsoleDestination(prefix: "vendor"), blockedKeys: ["email"]),
])
tracker.track("checkout_started", ["items": "3"])
tracker.track("newsletter_signup", ["email": "maneet@example.com"])
