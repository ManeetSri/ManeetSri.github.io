// Generated from src/dsa/design/content/lessons/sd-styles/sd-styles-layered.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// MARK: Data layer: where orders come from, in the server's shape
struct OrderRecord {
    let id: String
    let totalPence: Int
    let status: String          // "placed", "shipped", "delivered", "cancelled"
}

protocol OrderSource {
    func fetchRecords() throws -> [OrderRecord]
}

struct CannedOrderSource: OrderSource {
    func fetchRecords() throws -> [OrderRecord] {
        [
            OrderRecord(id: "A12", totalPence: 1850, status: "shipped"),
            OrderRecord(id: "A13", totalPence: 420, status: "cancelled"),
            OrderRecord(id: "A14", totalPence: 6400, status: "placed"),
        ]
    }
}

// MARK: Domain layer: the app's rules, in its own words
struct Order {
    let id: String
    let totalPence: Int
    let isOpen: Bool
}

struct OrdersService {
    let source: any OrderSource

    /// Open orders, largest first. Cancelled and delivered orders aren't open.
    func openOrders() throws -> [Order] {
        try source.fetchRecords()
            .map { Order(id: $0.id, totalPence: $0.totalPence, isOpen: !["cancelled", "delivered"].contains($0.status)) }
            .filter(\.isOpen)
            .sorted { $0.totalPence > $1.totalPence }
    }
}

// MARK: Presentation layer: what the screen shows
struct OrderRow {
    let title: String
    let detail: String
}

struct OrdersPresenter {
    let service: OrdersService

    func rows() -> [OrderRow] {
        do {
            return try service.openOrders().map { order in
                OrderRow(title: "Order \(order.id)", detail: String(format: "£%d.%02d", order.totalPence / 100, order.totalPence % 100))
            }
        } catch {
            return [OrderRow(title: "Couldn't load orders", detail: "Pull to try again")]
        }
    }
}

// The composition root wires the layers top to bottom
let presenter = OrdersPresenter(service: OrdersService(source: CannedOrderSource()))
for row in presenter.rows() {
    print(row.title, "·", row.detail)
}
