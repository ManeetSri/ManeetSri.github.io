// Generated from src/dsa/design/content/lessons/sd-principles/sd-principles-grasp-variation.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// The app's own vocabulary: designed from what features need, not from any vendor's API
enum AnalyticsEvent {
    case screenViewed(name: String)
    case addedToCart(productID: String, quantity: Int)
    case checkoutCompleted(totalPence: Int)

    var name: String {
        switch self {
        case .screenViewed: "screen_viewed"
        case .addedToCart: "added_to_cart"
        case .checkoutCompleted: "checkout_completed"
        }
    }

    var properties: [String: String] {
        switch self {
        case .screenViewed(let name): ["screen": name]
        case .addedToCart(let id, let quantity): ["product_id": id, "quantity": "\(quantity)"]
        case .checkoutCompleted(let total): ["total_pence": "\(total)"]
        }
    }
}

// Polymorphism: each provider is responsible for its own vendor's format
protocol AnalyticsProvider {
    func send(_ event: AnalyticsEvent)
}

struct VendorAAdapter: AnalyticsProvider {
    func send(_ event: AnalyticsEvent) {
        let properties = event.properties.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value)" }
        print("VendorA.logEvent(\(event.name), [\(properties.joined(separator: ", "))])")
    }
}

struct VendorBAdapter: AnalyticsProvider {
    func send(_ event: AnalyticsEvent) {
        if case .screenViewed(let name) = event {
            print("VendorB.screen(\(name))")          // vendor B has a separate screen API
        } else {
            let title = event.name.split(separator: "_").map { $0.prefix(1).uppercased() + $0.dropFirst() }
            print("VendorB.track(\(title.joined(separator: " ")))")
        }
    }
}

// Indirection: features talk to this, never to a vendor; consent is checked in one place
final class Analytics {
    private let providers: [any AnalyticsProvider]
    private let hasConsent: () -> Bool

    init(providers: [any AnalyticsProvider], hasConsent: @escaping () -> Bool) {
        self.providers = providers
        self.hasConsent = hasConsent
    }

    func track(_ event: AnalyticsEvent) {
        guard hasConsent() else { return }
        for provider in providers {
            provider.send(event)
        }
    }
}

let analytics = Analytics(providers: [VendorAAdapter(), VendorBAdapter()], hasConsent: { true })
analytics.track(.screenViewed(name: "orders"))
analytics.track(.addedToCart(productID: "p1", quantity: 2))
