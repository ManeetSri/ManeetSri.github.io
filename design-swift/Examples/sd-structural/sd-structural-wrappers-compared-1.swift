// Generated from src/dsa/design/content/lessons/sd-structural/sd-structural-wrappers-compared.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// The vendor's SDK: the adaptee
final class BeaconClient {
    func logEvent(_ name: String, parameters: [String: String]) {
        let pairs = parameters.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }
        print("    Beacon: \(name) \(pairs.joined(separator: " "))")
    }
}

enum AnalyticsEvent {
    case screenViewed(String)
    case purchased(totalPence: Int)
}

protocol AnalyticsTracking {
    func track(_ event: AnalyticsEvent)
}

// Adapter: makes Beacon's interface fit ours
struct BeaconAdapter: AnalyticsTracking {
    let client: BeaconClient

    func track(_ event: AnalyticsEvent) {
        switch event {
        case .screenViewed(let screen):
            client.logEvent("screen_view", parameters: ["screen": screen])
        case .purchased(let totalPence):
            client.logEvent("purchase", parameters: ["value_pence": String(totalPence)])
        }
    }
}

// Decorator: the same interface, plus a job (echoing events in debug builds)
struct DebugEcho: AnalyticsTracking {
    let wrapped: any AnalyticsTracking

    func track(_ event: AnalyticsEvent) {
        print("  debug: \(event)")
        wrapped.track(event)
    }
}

// Proxy: the same interface, controlling access to what's behind it
final class ConsentGate: AnalyticsTracking {
    private let wrapped: any AnalyticsTracking
    var hasConsent = false

    init(wrapping wrapped: any AnalyticsTracking) {
        self.wrapped = wrapped
    }

    func track(_ event: AnalyticsEvent) {
        guard hasConsent else {
            print("  gate: no consent, dropped")
            return
        }
        wrapped.track(event)
    }
}

// Facade: a new, simpler interface for the rest of the app
final class Analytics {
    private let gate: ConsentGate

    init(sending tracker: any AnalyticsTracking) {
        gate = ConsentGate(wrapping: tracker)
    }

    func consentChanged(to granted: Bool) { gate.hasConsent = granted }
    func screen(_ name: String) { gate.track(.screenViewed(name)) }
    func purchase(totalPence: Int) { gate.track(.purchased(totalPence: totalPence)) }
}

let analytics = Analytics(sending: DebugEcho(wrapped: BeaconAdapter(client: BeaconClient())))
print("Before the user answers:")
analytics.screen("Basket")
analytics.consentChanged(to: true)
print("After they agree:")
analytics.screen("Basket")
analytics.purchase(totalPence: 2499)
