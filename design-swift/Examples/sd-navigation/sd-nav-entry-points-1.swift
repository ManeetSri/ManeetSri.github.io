// Generated from src/dsa/design/content/lessons/sd-navigation/sd-nav-entry-points.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum AppRoute: Equatable {
    case order(id: String)
    case product(id: Int)
    case search
}

/// Where a route came from: for analytics, and for rules such as "notifications may switch tabs"
enum Source: String {
    case notification, widget, spotlight, quickAction, handoff
}

/// The one parser every entry point shares, for links on the shop's domain
func parse(_ url: URL) -> AppRoute? {
    let segments = url.pathComponents.filter { $0 != "/" }
    guard url.scheme == "https", url.host()?.lowercased() == "shop.example.com" else { return nil }
    switch (segments.first, segments.count) {
    case ("orders", 2): return .order(id: segments[1])
    case ("product", 2): return Int(segments[1]).map { .product(id: $0) }
    case ("search", 1): return .search
    default: return nil
    }
}

/// Each door's payload, adapted to a URL or a route, and nothing more
enum Arrival {
    case notification(userInfo: [String: Any])
    case widget(url: URL)
    case spotlight(identifier: String)
    case quickAction(type: String)
    case handoff(webpageURL: URL?)

    var source: Source {
        switch self {
        case .notification: .notification
        case .widget: .widget
        case .spotlight: .spotlight
        case .quickAction: .quickAction
        case .handoff: .handoff
        }
    }

    /// The route this arrival asks for, or nil when there is nothing to open
    var route: AppRoute? {
        switch self {
        case .notification(let userInfo):
            // New payloads carry a link; older app versions' payloads used a type and an id
            if let link = userInfo["link"] as? String, let url = URL(string: link) { return parse(url) }
            if userInfo["type"] as? String == "order_shipped", let id = userInfo["orderID"] as? String { return .order(id: id) }
            return nil
        case .widget(let url):
            return parse(url)
        case .spotlight(let identifier):
            return URL(string: identifier).flatMap(parse)   // items are indexed by their route's URL
        case .quickAction(let type):
            return type == "com.example.shop.search" ? .search : nil
        case .handoff(let webpageURL):
            return webpageURL.flatMap(parse)
        }
    }
}

let arrivals: [Arrival] = [
    .notification(userInfo: ["aps": ["alert": "Your order has shipped"], "link": "https://shop.example.com/orders/A1B2C3"]),
    .notification(userInfo: ["type": "order_shipped", "orderID": "Z9Y8X7"]),
    .widget(url: URL(string: "https://shop.example.com/orders/A1B2C3")!),
    .spotlight(identifier: "https://shop.example.com/product/42"),
    .quickAction(type: "com.example.shop.search"),
    .handoff(webpageURL: URL(string: "https://shop.example.com/product/42")),
    .notification(userInfo: ["type": "survey"]),
]
for arrival in arrivals {
    let outcome = arrival.route.map { "\($0)" } ?? "nothing to open: stay where the user is"
    print("\(arrival.source.rawValue) → \(outcome)")
}
