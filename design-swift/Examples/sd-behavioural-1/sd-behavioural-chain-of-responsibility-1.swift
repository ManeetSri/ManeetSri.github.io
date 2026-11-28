// Generated from src/dsa/design/content/lessons/sd-behavioural-1/sd-behavioural-chain-of-responsibility.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum Route: Equatable {
    case product(id: String)
    case order(id: String)
    case web(URL)
}

/// One link in the chain: returns a route if it recognises the link, or nil to pass it on
protocol DeepLinkHandler {
    func route(for url: URL) -> Route?
}

struct ProductLinks: DeepLinkHandler {
    func route(for url: URL) -> Route? {
        let parts = url.pathComponents
        guard parts.count == 3, parts[1] == "p" else { return nil }
        return .product(id: parts[2])
    }
}

struct OrderLinks: DeepLinkHandler {
    func route(for url: URL) -> Route? {
        let parts = url.pathComponents
        guard parts.count == 3, parts[1] == "orders" else { return nil }
        return .order(id: parts[2])
    }
}

/// The end of the chain: anything nobody recognised opens in Safari
struct OpenInBrowser: DeepLinkHandler {
    func route(for url: URL) -> Route? {
        .web(url)
    }
}

/// Asks each handler in turn; the first one that recognises the link wins
func route(_ url: URL, through handlers: [any DeepLinkHandler]) -> Route? {
    for handler in handlers {
        if let route = handler.route(for: url) {
            return route
        }
    }
    return nil
}

let chain: [any DeepLinkHandler] = [ProductLinks(), OrderLinks(), OpenInBrowser()]
for link in ["https://shop.example/p/mug-42", "https://shop.example/orders/981", "https://shop.example/help"] {
    print(route(URL(string: link)!, through: chain)!)
}
