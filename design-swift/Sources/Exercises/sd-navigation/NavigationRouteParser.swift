// Kata: Parse every entry point into a route (D20 · Routers and route enums, Deep links, Entry points)
import Foundation

public enum NavigationRouteParser {
    /// Every destination a link or a notification can name. Ids only, never loaded data.
    public enum Route: Equatable, Hashable, Sendable {
        case home
        case category(slug: String)
        case product(id: Int)
        case search(query: String)
        case basket
        case orders
        case order(id: String)
    }

    /// The app's custom URL scheme, as in `shop://product/42`
    public static let scheme = "shop"
    /// The hosts universal links arrive from
    public static let hosts: Set<String> = ["shop.example.com", "www.shop.example.com"]

    /// The route a custom-scheme URL or universal link names, or nil if the URL isn't ours or is malformed
    public static func route(from url: URL) -> Route? {
        // Write your solution here, then run:
        // swift test --filter NavigationRouteParserTests
        return nil
    }

    /// The route a notification's payload asks for, or nil when there's nothing to open
    public static func route(fromNotification userInfo: [AnyHashable: Any]) -> Route? {
        return nil
    }

    /// The universal link for `route`, on https://shop.example.com. Parsing it must give `route` back.
    public static func url(for route: Route) -> URL {
        return URL(filePath: "/")
    }
}
