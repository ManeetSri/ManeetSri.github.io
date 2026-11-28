// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-builder.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

@resultBuilder
enum QueryBuilder {
    static func buildExpression(_ item: URLQueryItem) -> [URLQueryItem] { [item] }
    static func buildBlock(_ parts: [URLQueryItem]...) -> [URLQueryItem] { parts.flatMap { $0 } }
    static func buildOptional(_ part: [URLQueryItem]?) -> [URLQueryItem] { part ?? [] }
    static func buildEither(first part: [URLQueryItem]) -> [URLQueryItem] { part }
    static func buildEither(second part: [URLQueryItem]) -> [URLQueryItem] { part }
    static func buildArray(_ parts: [[URLQueryItem]]) -> [URLQueryItem] { parts.flatMap { $0 } }
}

func searchQuery(@QueryBuilder _ items: () -> [URLQueryItem]) -> String {
    var components = URLComponents()
    components.queryItems = items()
    return components.percentEncodedQuery ?? ""
}

func productSearch(text: String, page: Int, tags: [String], inStockOnly: Bool) -> String {
    searchQuery {
        URLQueryItem(name: "q", value: text)
        if page > 1 {
            URLQueryItem(name: "page", value: String(page))
        }
        for tag in tags {
            URLQueryItem(name: "tag", value: tag)
        }
        if inStockOnly {
            URLQueryItem(name: "stock", value: "in")
        } else {
            URLQueryItem(name: "stock", value: "any")
        }
    }
}

print(productSearch(text: "green tea", page: 1, tags: [], inStockOnly: false))
print(productSearch(text: "green tea", page: 3, tags: ["loose", "organic"], inStockOnly: true))
