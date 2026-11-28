import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NavigationRouteParserTests {
    typealias Route = NavigationRouteParser.Route

    private func parse(_ text: String) -> Route? {
        guard let url = URL(string: text) else { return nil }
        return NavigationRouteParser.route(from: url)
    }

    /// A notification payload as APNs delivers it: JSON, so numbers arrive as NSNumber
    private func payload(_ json: String) throws -> [AnyHashable: Any] {
        let object = try JSONSerialization.jsonObject(with: Data(json.utf8))
        return try #require(object as? [AnyHashable: Any])
    }

    // MARK: - URLs

    @Test("Both custom-scheme forms mean the same route", arguments: [
        "shop://product/42",
        "shop:///product/42",
        "SHOP://product/42",
    ])
    func customScheme(link: String) {
        #expect(parse(link) == .product(id: 42))
    }

    @Test("Universal links on either host, whatever the host's case, with extras ignored", arguments: [
        "https://shop.example.com/product/42",
        "https://www.shop.example.com/product/42",
        "https://Shop.Example.COM/product/42",
        "https://shop.example.com/product/42/",
        "https://shop.example.com/product/42?utm_source=email&utm_campaign=spring",
        "https://shop.example.com/product/42#reviews",
    ])
    func universalLinks(link: String) {
        #expect(parse(link) == .product(id: 42))
    }

    @Test("Every route has a link", arguments: [
        ("https://shop.example.com", Route.home),
        ("https://shop.example.com/", Route.home),
        ("shop://", Route.home),
        ("https://shop.example.com/category/running-shoes", Route.category(slug: "running-shoes")),
        ("shop://category/sale-2026", Route.category(slug: "sale-2026")),
        ("https://shop.example.com/basket", Route.basket),
        ("shop://basket", Route.basket),
        ("https://shop.example.com/orders", Route.orders),
        ("https://shop.example.com/orders/A1B2C3", Route.order(id: "A1B2C3")),
        ("shop://orders/Z9Y8X7W6V5", Route.order(id: "Z9Y8X7W6V5")),
    ])
    func everyRoute(link: String, expected: Route) {
        #expect(parse(link) == expected)
    }

    @Test("Literal segments ignore case; ids keep theirs", arguments: [
        ("https://shop.example.com/Product/42", Route.product(id: 42)),
        ("https://shop.example.com/BASKET", Route.basket),
        ("shop://Orders/A1B2C3", Route.order(id: "A1B2C3")),
    ])
    func literalCase(link: String, expected: Route) {
        #expect(parse(link) == expected)
    }

    @Test("Links that aren't ours are rejected", arguments: [
        "http://shop.example.com/product/42",
        "https://shop.example.net/product/42",
        "https://shop.example.com.evil.example/product/42",
        "https://evil.example/shop.example.com/product/42",
        "ftp://shop.example.com/product/42",
        "shopping://product/42",
        "mailto:help@shop.example.com",
    ])
    func notOurs(link: String) {
        #expect(parse(link) == nil)
    }

    @Test("Malformed product ids are rejected", arguments: [
        "https://shop.example.com/product/0",
        "https://shop.example.com/product/-3",
        "https://shop.example.com/product/+42",
        "https://shop.example.com/product/4.2",
        "https://shop.example.com/product/abc",
        "https://shop.example.com/product/1234567890",
        "https://shop.example.com/product/%34%32x",
        "https://shop.example.com/product",
        "https://shop.example.com/product/42/extra",
    ])
    func badProductIDs(link: String) {
        #expect(parse(link) == nil)
    }

    @Test("A leading zero is still a product id")
    func leadingZero() {
        #expect(parse("https://shop.example.com/product/042") == .product(id: 42))
        #expect(parse("https://shop.example.com/product/999999999") == .product(id: 999_999_999))
    }

    @Test("Malformed order ids and slugs are rejected", arguments: [
        "https://shop.example.com/orders/a1b2c3",
        "https://shop.example.com/orders/A1B2",
        "https://shop.example.com/orders/A1B2C3D4E5F",
        "https://shop.example.com/orders/A1B2-C3",
        "https://shop.example.com/orders/A1B2C3/tracking",
        "https://shop.example.com/category/Shoes",
        "https://shop.example.com/category/sale_2026",
        "https://shop.example.com/category",
        "https://shop.example.com/category/\(String(repeating: "a", count: 41))",
        "https://shop.example.com/help/returns",
        "https://shop.example.com/basket/clear",
    ])
    func badIDsAndPaths(link: String) {
        #expect(parse(link) == nil)
    }

    @Test("Search reads q: percent-decoded, plus as a space, trimmed", arguments: [
        ("https://shop.example.com/search?q=trail%20shoes", "trail shoes"),
        ("https://shop.example.com/search?q=trail+shoes", "trail shoes"),
        ("https://shop.example.com/search?q=c%2B%2B", "c++"),
        ("https://shop.example.com/search?q=%20%20boots%20", "boots"),
        ("https://shop.example.com/search?utm_source=ad&q=caf%C3%A9", "café"),
        ("shop://search?q=50%25%20off", "50% off"),
    ])
    func search(link: String, query: String) {
        #expect(parse(link) == .search(query: query))
    }

    @Test("A search needs a real query", arguments: [
        "https://shop.example.com/search",
        "https://shop.example.com/search?q=",
        "https://shop.example.com/search?q=%20%20",
        "https://shop.example.com/search?query=boots",
        "https://shop.example.com/search?q=\(String(repeating: "a", count: 101))",
    ])
    func badSearch(link: String) {
        #expect(parse(link) == nil)
    }

    // MARK: - Notifications

    @Test("A payload's link decides its route")
    func notificationLink() {
        let userInfo: [AnyHashable: Any] = [
            "aps": ["alert": "Your order has shipped"],
            "link": "https://shop.example.com/orders/A1B2C3",
        ]
        #expect(NavigationRouteParser.route(fromNotification: userInfo) == .order(id: "A1B2C3"))
    }

    @Test("A link that doesn't parse opens nothing, even with the older fields present")
    func badNotificationLink() {
        let userInfo: [AnyHashable: Any] = [
            "link": "https://shop.example.com/orders/nope",
            "type": "order_shipped",
            "orderID": "A1B2C3",
        ]
        #expect(NavigationRouteParser.route(fromNotification: userInfo) == nil)
        #expect(NavigationRouteParser.route(fromNotification: ["link": 42]) == nil)
    }

    @Test("Older payloads use a type and an id")
    func legacyPayloads() {
        #expect(NavigationRouteParser.route(fromNotification: ["type": "order_shipped", "orderID": "A1B2C3"]) == .order(id: "A1B2C3"))
        #expect(NavigationRouteParser.route(fromNotification: ["type": "order_delivered", "orderID": "Z9Y8X7"]) == .order(id: "Z9Y8X7"))
        #expect(NavigationRouteParser.route(fromNotification: ["type": "price_drop", "productID": 42]) == .product(id: 42))
        #expect(NavigationRouteParser.route(fromNotification: ["type": "price_drop", "productID": "42"]) == .product(id: 42))
        #expect(NavigationRouteParser.route(fromNotification: ["type": "basket_reminder"]) == .basket)
    }

    @Test("Older payloads with missing or bad fields open nothing")
    func badLegacyPayloads() {
        #expect(NavigationRouteParser.route(fromNotification: ["type": "order_shipped"]) == nil)
        #expect(NavigationRouteParser.route(fromNotification: ["type": "order_shipped", "orderID": "short"]) == nil)
        #expect(NavigationRouteParser.route(fromNotification: ["type": "price_drop", "productID": 0]) == nil)
        #expect(NavigationRouteParser.route(fromNotification: ["type": "price_drop", "productID": "abc"]) == nil)
        #expect(NavigationRouteParser.route(fromNotification: ["type": "survey"]) == nil)
        #expect(NavigationRouteParser.route(fromNotification: [:]) == nil)
    }

    @Test("Payloads decoded from JSON, as APNs delivers them")
    func jsonPayloads() throws {
        let shipped = try payload(#"{"aps":{"alert":{"title":"Shipped"}},"type":"order_shipped","orderID":"A1B2C3"}"#)
        #expect(NavigationRouteParser.route(fromNotification: shipped) == .order(id: "A1B2C3"))
        let drop = try payload(#"{"aps":{"alert":"Price drop"},"type":"price_drop","productID":42}"#)
        #expect(NavigationRouteParser.route(fromNotification: drop) == .product(id: 42))
        let linked = try payload(#"{"aps":{"alert":"New in"},"link":"https://www.shop.example.com/category/new-in"}"#)
        #expect(NavigationRouteParser.route(fromNotification: linked) == .category(slug: "new-in"))
    }

    // MARK: - Generating links

    @Test("Links are generated on the main host")
    func generatedLinks() {
        #expect(NavigationRouteParser.url(for: .product(id: 42)).absoluteString == "https://shop.example.com/product/42")
        #expect(NavigationRouteParser.url(for: .order(id: "A1B2C3")).absoluteString == "https://shop.example.com/orders/A1B2C3")
        #expect(NavigationRouteParser.url(for: .category(slug: "new-in")).absoluteString == "https://shop.example.com/category/new-in")
        #expect(NavigationRouteParser.url(for: .basket).absoluteString == "https://shop.example.com/basket")
    }

    @Test("Every route survives a round trip through its link", arguments: [
        Route.home,
        .category(slug: "running-shoes"),
        .product(id: 7),
        .basket,
        .orders,
        .order(id: "A1B2C3"),
        .search(query: "trail shoes"),
        .search(query: "c++"),
        .search(query: "50% off"),
        .search(query: "café & bar"),
        .search(query: "size=10 #new?"),
    ])
    func roundTrip(route: Route) {
        let url = NavigationRouteParser.url(for: route)
        #expect(url.scheme == "https" && url.host() == "shop.example.com")
        #expect(NavigationRouteParser.route(from: url) == route)
    }
}
