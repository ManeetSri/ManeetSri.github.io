// Generated from src/dsa/design/content/lessons/sd-coupling/sd-coupling-connascence.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// The only place that knows what the server's numbers mean
enum OrderStatus: Int, Decodable {
    case placed = 0, packed = 1, shipped = 2, delivered = 3
    case unknown = -1

    // A newer server may send a status this build has never heard of
    init(from decoder: any Decoder) throws {
        let code = try decoder.singleValueContainer().decode(Int.self)
        self = OrderStatus(rawValue: code) ?? .unknown
    }
}

struct Order: Decodable {
    let id: String
    let status: OrderStatus
}

func badge(for order: Order) -> String {
    switch order.status {
    case .placed, .packed: "Preparing"
    case .shipped: "On its way"
    case .delivered: "Delivered"
    case .unknown: "Updating…"
    }
}

let json = Data(#"[{"id": "A1", "status": 2}, {"id": "B7", "status": 4}]"#.utf8)
for order in try JSONDecoder().decode([Order].self, from: json) {
    print("\(order.id): \(badge(for: order))")
}
