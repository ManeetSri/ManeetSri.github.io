// Generated from src/dsa/design/content/lessons/sd-structural/sd-structural-adapter.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// The vendor's SDK. You can't change it.
final class BeaconClient {
    func logEvent(_ name: String, parameters: [String: String]) {
        let pairs = parameters.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }
        print("Beacon: \(name) \(pairs.joined(separator: " "))")
    }
}

// The target: shaped by what the app needs, not by Beacon
enum AnalyticsEvent {
    case screenViewed(String)
    case addedToBasket(productID: String, quantity: Int)
    case checkoutCompleted(totalPence: Int)
}

protocol AnalyticsTracking {
    func track(_ event: AnalyticsEvent)
}

// The adapter: the only type that knows Beacon's names and formats
struct BeaconAnalytics: AnalyticsTracking {
    let client: BeaconClient

    func track(_ event: AnalyticsEvent) {
        switch event {
        case .screenViewed(let name):
            client.logEvent("screen_view", parameters: ["screen_name": name])
        case .addedToBasket(let productID, let quantity):
            client.logEvent("add_to_cart", parameters: ["item_id": productID, "quantity": String(quantity)])
        case .checkoutCompleted(let totalPence):
            let pounds = "\(totalPence / 100).\(String(format: "%02d", totalPence % 100))"
            client.logEvent("purchase", parameters: ["value": pounds, "currency": "GBP"])
        }
    }
}

// A second implementation of the same target, for tests and previews
final class RecordingAnalytics: AnalyticsTracking {
    private(set) var events: [AnalyticsEvent] = []
    func track(_ event: AnalyticsEvent) { events.append(event) }
}

let analytics: any AnalyticsTracking = BeaconAnalytics(client: BeaconClient())
analytics.track(.screenViewed("Basket"))
analytics.track(.addedToBasket(productID: "sku-42", quantity: 2))
analytics.track(.checkoutCompleted(totalPence: 2499))

let recorder = RecordingAnalytics()
recorder.track(.checkoutCompleted(totalPence: 2499))
print("The fake recorded \(recorder.events.count) event, and Beacon saw nothing")
