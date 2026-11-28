// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-static-factories.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct Profile: Decodable { let name: String }
struct Order: Decodable { let id: Int }

struct Endpoint<Response: Decodable> {
    let method: String
    let path: String
    var query: [URLQueryItem] = []
}

extension Endpoint where Response == Profile {
    static func profile(id: Int) -> Endpoint {
        Endpoint(method: "GET", path: "/users/\(id)")
    }
}

extension Endpoint where Response == [Order] {
    static func orders(page: Int) -> Endpoint {
        Endpoint(method: "GET", path: "/orders", query: [URLQueryItem(name: "page", value: String(page))])
    }
}

// Stands in for an API client's send(_:): the endpoint carries its response type
func describe<Response>(_ endpoint: Endpoint<Response>) -> String {
    let query = endpoint.query.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
    return "\(endpoint.method) \(endpoint.path)\(query.isEmpty ? "" : "?" + query) -> \(Response.self)"
}

print(describe(.profile(id: 42)))
print(describe(.orders(page: 2)))
