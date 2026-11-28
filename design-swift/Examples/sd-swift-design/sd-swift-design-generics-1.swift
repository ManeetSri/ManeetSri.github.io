// Generated from src/dsa/design/content/lessons/sd-swift-design/sd-swift-design-generics.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

protocol Endpoint {
    associatedtype Response: Decodable
    var path: String { get }
}

struct User: Decodable { let name: String }
struct Order: Decodable { let id: Int; let pence: Int }

struct UserEndpoint: Endpoint {
    typealias Response = User
    let id: Int
    var path: String { "/users/\(id)" }
}

struct OrdersEndpoint: Endpoint {
    typealias Response = [Order]
    var path: String { "/orders" }
}

struct APIClient {
    // Stands in for the network: canned JSON for each path
    let responses: [String: String]

    func send<E: Endpoint>(_ endpoint: E) throws -> E.Response {
        let json = responses[endpoint.path] ?? "null"
        return try JSONDecoder().decode(E.Response.self, from: Data(json.utf8))
    }
}

let client = APIClient(responses: [
    "/users/7": #"{"name": "Maneet"}"#,
    "/orders": #"[{"id": 1, "pence": 1250}, {"id": 2, "pence": 899}]"#,
])

let user = try client.send(UserEndpoint(id: 7))    // a User: no cast, no Any
let orders = try client.send(OrdersEndpoint())     // an [Order]
print(user.name)
print(orders.map(\.pence).reduce(0, +))
