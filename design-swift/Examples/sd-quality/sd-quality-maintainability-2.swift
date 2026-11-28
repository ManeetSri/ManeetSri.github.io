// Generated from src/dsa/design/content/lessons/sd-quality/sd-quality-maintainability.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum OrderStatus: Decodable, Equatable {
    case placed, shipped, refunded
    case unknown(String)

    init(from decoder: any Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        switch raw {
        case "placed": self = .placed
        case "shipped": self = .shipped
        case "refunded": self = .refunded
        default: self = .unknown(raw)
        }
    }

    var label: String {
        switch self {
        case .placed: "Placed"
        case .shipped: "On its way"
        case .refunded: "Refunded"
        case .unknown: "Update the app to see this status"
        }
    }
}

struct Order: Decodable {
    let id: Int
    let status: OrderStatus
}

let json = Data(#"[{"id": 1, "status": "shipped"}, {"id": 2, "status": "partially_refunded"}]"#.utf8)
for order in try JSONDecoder().decode([Order].self, from: json) {
    print("Order \(order.id): \(order.status.label)")
}
