// Generated from src/dsa/design/content/lessons/sd-refactoring/sd-refactoring-api-smells.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

enum AnalyticsEvent {
    case viewedProduct(id: String)
    case addedToBasket(productID: String, pence: Int)
    case checkoutFailed(reason: CheckoutFailure)

    enum CheckoutFailure: String {
        case cardDeclined = "card_declined"
        case outOfStock = "out_of_stock"
    }

    // The one place the analytics names and keys are spelled out: the boundary with the SDK
    var name: String {
        switch self {
        case .viewedProduct: "product_viewed"
        case .addedToBasket: "basket_added"
        case .checkoutFailed: "checkout_failed"
        }
    }

    var parameters: [String: String] {
        switch self {
        case .viewedProduct(let id): ["product_id": id]
        case .addedToBasket(let id, let pence): ["product_id": id, "value_pence": String(pence)]
        case .checkoutFailed(let reason): ["reason": reason.rawValue]
        }
    }
}

protocol AnalyticsTracking {
    func track(_ event: AnalyticsEvent)
}

// Stands in for the SDK adapter: it's the only code that sees the strings
struct PrintingTracker: AnalyticsTracking {
    func track(_ event: AnalyticsEvent) {
        let parameters = event.parameters.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }
        print(event.name, parameters.joined(separator: " "))
    }
}

let tracker = PrintingTracker()
tracker.track(.viewedProduct(id: "sku-42"))
tracker.track(.addedToBasket(productID: "sku-42", pence: 1999))
tracker.track(.checkoutFailed(reason: .cardDeclined))
