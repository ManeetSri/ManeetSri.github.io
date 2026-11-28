// Generated from src/dsa/design/content/lessons/sd-navigation/sd-nav-routers.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum Tab: String {
    case home, search, basket, account
}

/// Where to go, by id. Nothing about how it's shown.
enum AppRoute: Equatable {
    case product(id: Int)
    case search(query: String)
    case basket
    case order(id: String)
}

/// What the UI layer should do: the only part that touches UIKit or SwiftUI
struct Plan: CustomStringConvertible {
    var dismissPresented = false
    var signInFirst = false
    var tab: Tab
    var screens: [String] = []

    var description: String {
        var steps: [String] = []
        if dismissPresented { steps.append("dismiss") }
        if signInFirst { steps.append("sign in") }
        steps.append("\(tab.rawValue): [\(screens.joined(separator: ", "))]")
        return steps.joined(separator: " → ")
    }
}

struct Router {
    static let scheme = "shop"
    static let host = "shop.example.com"

    /// 1. Parse: a custom-scheme URL and a universal link mean the same route
    func route(for url: URL) -> AppRoute? {
        var segments = url.pathComponents.filter { $0 != "/" }
        switch url.scheme?.lowercased() {
        case Self.scheme:
            // shop://product/42 puts "product" in the host, not the path
            if let host = url.host() { segments.insert(host, at: 0) }
        case "https" where url.host()?.lowercased() == Self.host:
            break
        default:
            return nil   // someone else's link
        }
        let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        switch (segments.first, segments.count) {
        case ("product", 2):
            guard let id = Int(segments[1]), id > 0 else { return nil }   // links are untrusted input
            return .product(id: id)
        case ("search", 1):
            guard let text = query?.first(where: { $0.name == "q" })?.value, !text.isEmpty else { return nil }
            return .search(query: text)
        case ("basket", 1):
            return .basket
        case ("orders", 2):
            return .order(id: segments[1])
        default:
            return nil
        }
    }

    /// 2 and 3. Check what the route needs, then plan it against what's on screen now
    func plan(for route: AppRoute, isSignedIn: Bool, isPresenting: Bool) -> Plan {
        var plan: Plan
        switch route {
        case .product(let id):
            plan = Plan(tab: .home, screens: ["product \(id)"])
        case .search(let query):
            plan = Plan(tab: .search, screens: ["results for \"\(query)\""])
        case .basket:
            plan = Plan(tab: .basket)
        case .order(let id):
            plan = Plan(tab: .account, screens: ["orders", "order \(id)"])
            plan.signInFirst = !isSignedIn
        }
        plan.dismissPresented = isPresenting   // never push behind a sheet
        return plan
    }
}

let router = Router()
// The user is signed out, with a sheet open, when each link arrives
let links = [
    "shop://product/42",
    "https://shop.example.com/search?q=trail%20shoes",
    "https://shop.example.com/orders/A1B2C3",
    "shop://product/abc",
    "https://phish.example.net/basket",
]
for link in links {
    guard let url = URL(string: link), let route = router.route(for: url) else {
        print("\(link)\n  → rejected")
        continue
    }
    let plan = router.plan(for: route, isSignedIn: false, isPresenting: true)
    print("\(link)\n  → \(route)\n  → \(plan)")
}
