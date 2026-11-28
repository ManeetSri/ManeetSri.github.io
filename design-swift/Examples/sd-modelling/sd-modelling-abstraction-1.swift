// Generated from src/dsa/design/content/lessons/sd-modelling/sd-modelling-abstraction.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct Basket {
    struct Line { let sku: String; let quantity: Int }
    let lines: [Line]
}

struct Order: Identifiable {
    let id: String
    let lineCount: Int
}

enum CheckoutError: Error { case emptyBasket }

protocol OrderPlacing: Sendable {
    func place(_ basket: Basket) async throws -> Order
}

protocol ReceiptStoring: Sendable {
    func save(_ order: Order) async throws
}

struct Checkout {
    let orders: any OrderPlacing
    let receipts: any ReceiptStoring

    // One level: the steps of checking out, in the product's words
    func placeOrder(_ basket: Basket) async throws -> Order.ID {
        guard !basket.lines.isEmpty else { throw CheckoutError.emptyBasket }
        let order = try await orders.place(basket)
        try await receipts.save(order)
        return order.id
    }
}

// The level below lives in its own types: how an order travels, where receipts go
struct FakeOrdersAPI: OrderPlacing {
    func place(_ basket: Basket) async throws -> Order {
        print("POST /v2/orders with \(basket.lines.count) lines")
        return Order(id: "ord_812", lineCount: basket.lines.count)
    }
}

actor InMemoryReceipts: ReceiptStoring {
    private(set) var saved: [Order.ID] = []
    func save(_ order: Order) { saved.append(order.id) }
}

let receipts = InMemoryReceipts()
let checkout = Checkout(orders: FakeOrdersAPI(), receipts: receipts)
let basket = Basket(lines: [.init(sku: "TEE-M-BLUE", quantity: 2), .init(sku: "SOCK-3PK", quantity: 1)])
let id = try await checkout.placeOrder(basket)
print("Placed \(id)")
print("Receipts: \(await receipts.saved)")

do {
    _ = try await checkout.placeOrder(Basket(lines: []))
} catch {
    print("Empty basket: \(error)")
}
