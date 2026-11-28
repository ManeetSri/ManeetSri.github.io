// Reference solution: Parse every entry point into a route. Both URL forms are normalised into one
// list of path segments first, so a single table of routes serves custom schemes and universal links;
// every parameter is validated by hand, because links are untrusted input. Notifications reuse the
// URL parser through their `link` field, with the older typed format as a fallback.
import Foundation

public enum NavigationRouteParser {
    public enum Route: Equatable, Hashable, Sendable {
        case home
        case category(slug: String)
        case product(id: Int)
        case search(query: String)
        case basket
        case orders
        case order(id: String)
    }

    public static let scheme = "shop"
    public static let hosts: Set<String> = ["shop.example.com", "www.shop.example.com"]

    public static func route(from url: URL) -> Route? {
        guard let segments = segments(of: url) else { return nil }
        let literal = segments.first?.lowercased()
        switch (literal, segments.count) {
        case (nil, _):
            return .home
        case ("category", 2):
            return isSlug(segments[1]) ? .category(slug: segments[1]) : nil
        case ("product", 2):
            return productID(segments[1]).map { .product(id: $0) }
        case ("search", 1):
            return searchQuery(in: url).map { .search(query: $0) }
        case ("basket", 1):
            return .basket
        case ("orders", 1):
            return .orders
        case ("orders", 2):
            return isOrderID(segments[1]) ? .order(id: segments[1]) : nil
        default:
            return nil
        }
    }

    public static func route(fromNotification userInfo: [AnyHashable: Any]) -> Route? {
        // A payload with a link is decided by its link, even if it also has the older fields
        if let link = userInfo["link"] {
            guard let text = link as? String, let url = URL(string: text) else { return nil }
            return route(from: url)
        }
        switch userInfo["type"] as? String {
        case "order_shipped", "order_delivered":
            guard let id = userInfo["orderID"] as? String, isOrderID(id) else { return nil }
            return .order(id: id)
        case "price_drop":
            if let id = userInfo["productID"] as? Int { return id > 0 ? .product(id: id) : nil }
            if let text = userInfo["productID"] as? String { return productID(text).map { .product(id: $0) } }
            return nil
        case "basket_reminder":
            return .basket
        default:
            return nil
        }
    }

    public static func url(for route: Route) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "shop.example.com"
        switch route {
        case .home:
            components.path = "/"
        case .category(let slug):
            components.path = "/category/\(slug)"
        case .product(let id):
            components.path = "/product/\(id)"
        case .search(let query):
            components.path = "/search"
            // `+` must be encoded too: the parser reads a bare `+` as a space, as HTML forms write it
            var allowed = CharacterSet.urlQueryAllowed
            allowed.remove(charactersIn: "+&=")
            components.percentEncodedQuery = "q=" + (query.addingPercentEncoding(withAllowedCharacters: allowed) ?? "")
        case .basket:
            components.path = "/basket"
        case .orders:
            components.path = "/orders"
        case .order(let id):
            components.path = "/orders/\(id)"
        }
        return components.url ?? URL(filePath: "/")
    }

    // MARK: - Helpers

    /// The URL's path segments, with a custom scheme's host as the first one; nil if the URL isn't ours
    private static func segments(of url: URL) -> [String]? {
        var segments = url.pathComponents.filter { $0 != "/" && !$0.isEmpty }
        switch url.scheme?.lowercased() {
        case scheme:
            // shop://product/42 parses "product" as the host; shop:///product/42 has no host
            if let host = url.host(), !host.isEmpty { segments.insert(host, at: 0) }
        case "https":
            guard let host = url.host()?.lowercased(), hosts.contains(host) else { return nil }
        default:
            return nil
        }
        return segments
    }

    /// 1–9 ASCII digits with a value above zero. `Int("+42")` succeeds, so check the characters first.
    private static func productID(_ text: String) -> Int? {
        guard (1...9).contains(text.count), text.allSatisfy({ $0.isASCII && $0.isNumber }), let id = Int(text), id > 0 else { return nil }
        return id
    }

    /// 1–40 characters: lowercase ASCII letters, digits and hyphens
    private static func isSlug(_ text: String) -> Bool {
        (1...40).contains(text.count) && text.allSatisfy { $0.isASCII && ($0.isLowercase || $0.isNumber || $0 == "-") }
    }

    /// 6–10 characters: uppercase ASCII letters and digits
    private static func isOrderID(_ text: String) -> Bool {
        (6...10).contains(text.count) && text.allSatisfy { $0.isASCII && ($0.isUppercase || $0.isNumber) }
    }

    /// The `q` parameter with `+` read as a space, percent-decoded, trimmed, 1–100 characters
    private static func searchQuery(in url: URL) -> String? {
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.percentEncodedQueryItems ?? []
        guard let raw = items.first(where: { $0.name == "q" })?.value,
              let decoded = raw.replacingOccurrences(of: "+", with: "%20").removingPercentEncoding
        else { return nil }
        let query = decoded.trimmingCharacters(in: .whitespacesAndNewlines)
        return (1...100).contains(query.count) ? query : nil
    }
}
