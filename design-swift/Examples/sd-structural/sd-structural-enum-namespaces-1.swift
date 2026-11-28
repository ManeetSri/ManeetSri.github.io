// Generated from src/dsa/design/content/lessons/sd-structural/sd-structural-enum-namespaces.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

enum Theme {
    enum Spacing {
        static let small = 8.0
        static let medium = 16.0
        static let large = 24.0
    }

    enum Radius {
        static let card = 12.0
        static let button = 22.0
    }
}

enum API {
    static let version = "v2"

    enum Endpoint {
        static func orders(page: Int) -> String { "/\(API.version)/orders?page=\(page)" }
        static func order(id: String) -> String { "/\(API.version)/orders/\(id)" }
    }
}

// A namespace can grow across files: this extension could live anywhere in the module
extension API {
    enum Header {
        static let requestID = "X-Request-ID"
    }
}

print(Theme.Spacing.medium + Theme.Radius.card)
print(API.Endpoint.orders(page: 2))
print(API.Endpoint.order(id: "A1042"))
print(API.Header.requestID)
