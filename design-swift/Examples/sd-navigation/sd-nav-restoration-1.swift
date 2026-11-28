// Generated from src/dsa/design/content/lessons/sd-navigation/sd-nav-restoration.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum Tab: String, Codable, CaseIterable {
    case home, search, basket, account
}

enum Route: Codable, Equatable {
    case category(slug: String)
    case product(id: Int)
    case orders
    case order(id: String)
}

/// What a window saves: small, ids only, versioned, and tied to the user it belongs to
struct Snapshot: Codable {
    static let version = 2
    var version = Snapshot.version
    var userID: String
    var savedAt: Double   // seconds since 1970
    var tab: Tab
    var paths: [String: [Route]]
}

/// Decodes one value, or nil if this build can't read it, so one bad route doesn't cost the rest
struct Lenient<Value: Decodable>: Decodable {
    let value: Value?
    init(from decoder: any Decoder) throws {
        value = try? Value(from: decoder)
    }
}

/// The same snapshot, read without trusting it
struct SavedSnapshot: Decodable {
    var version: Int
    var userID: String
    var savedAt: Double
    var tab: Lenient<Tab>
    var paths: [String: [Lenient<Route>]]
}

struct Navigation {
    var tab = Tab.home
    var paths: [Tab: [Route]] = [:]

    /// An entry point's route lands on its own tab and replaces that tab's stack; other tabs keep theirs
    mutating func open(_ route: Route) {
        switch route {
        case .category, .product: tab = .home; paths[.home] = [route]
        case .orders: tab = .account; paths[.account] = [.orders]
        case .order: tab = .account; paths[.account] = [.orders, route]
        }
    }

    var summary: String {
        let stacks = Tab.allCases.compactMap { tab -> String? in
            guard let path = paths[tab], !path.isEmpty else { return nil }
            return "\(tab.rawValue) [" + path.map(\.name).joined(separator: ", ") + "]"
        }
        return (["on \(tab.rawValue)"] + stacks).joined(separator: " | ")
    }
}

extension Route {
    var name: String {
        switch self {
        case .category(let slug): "category \(slug)"
        case .product(let id): "product \(id)"
        case .orders: "orders"
        case .order(let id): "order \(id)"
        }
    }
}

/// Restoring never crashes and never shows what shouldn't come back
func restore(_ data: Data, user: String, now: Double, existingOrders: Set<String>) -> Navigation {
    guard let saved = try? JSONDecoder().decode(SavedSnapshot.self, from: data),
          saved.version == Snapshot.version,
          saved.userID == user                  // never restore another account's screens
    else { return Navigation() }

    var navigation = Navigation(tab: saved.tab.value ?? .home)
    guard now - saved.savedAt < 8 * 3600 else { return navigation }   // old: keep the tab, start stacks at their roots

    for (key, routes) in saved.paths {
        guard let tab = Tab(rawValue: key) else { continue }
        var kept: [Route] = []
        for item in routes {
            // A route this build can't read, or whose data has gone, ends the stack there
            guard let route = item.value else { break }
            if case .order(let id) = route, !existingOrders.contains(id) { break }
            kept.append(route)
        }
        navigation.paths[tab] = kept
    }
    return navigation
}

let now = 1_800_000_000.0
let orders: Set<String> = ["A1B2C3"]
func encoded(_ snapshot: Snapshot) throws -> Data { try JSONEncoder().encode(snapshot) }
let usual = Snapshot(userID: "u1", savedAt: now - 600, tab: .basket, paths: [
    "home": [.category(slug: "shoes"), .product(id: 7)],
    "account": [.orders, .order(id: "A1B2C3")],
])

var orderGone = usual
orderGone.paths["account"] = [.orders, .order(id: "Z9Y8X7")]
var weekOld = usual
weekOld.savedAt = now - 7 * 86_400
// Saved before gift cards were removed from the app
let fromOldBuild = #"{"version":2,"userID":"u1","savedAt":1799999400,"tab":"home","paths":{"home":[{"category":{"slug":"shoes"}},{"giftCard":{"code":"XMAS"}},{"product":{"id":7}}]}}"#

let cases: [(String, Data, String)] = [
    ("Saved ten minutes ago", try encoded(usual), "u1"),
    ("Order deleted since", try encoded(orderGone), "u1"),
    ("A route this build no longer has", Data(fromOldBuild.utf8), "u1"),
    ("Saved a week ago", try encoded(weekOld), "u1"),
    ("Another user signed in", try encoded(usual), "u2"),
    ("Not JSON at all", Data("garbage".utf8), "u1"),
]
for (label, data, user) in cases {
    print("\(label): \(restore(data, user: user, now: now, existingOrders: orders).summary)")
}

// Cold start from a link: restore first, then the link's route wins its own tab
var launched = restore(try encoded(usual), user: "u1", now: now, existingOrders: orders)
launched.open(.product(id: 42))
print("Restored, then a link to product 42: \(launched.summary)")
