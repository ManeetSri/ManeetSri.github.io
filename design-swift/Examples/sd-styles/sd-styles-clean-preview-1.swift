// Generated from src/dsa/design/content/lessons/sd-styles/sd-styles-clean-preview.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// MARK: The core. No UIKit, SwiftData or URLSession: only the rules, and the ports they need.
struct Order: Sendable {
    let id: String
    let totalPence: Int
    let receipt: String
}

enum CheckoutError: Error {
    case emptyBasket
    case declined
}

/// A port: what the core needs from a payment provider, in the core's own words
protocol PaymentPort: Sendable {
    func charge(pence: Int, reference: String) async throws -> String
}

/// A port for keeping orders, whatever the storage turns out to be
protocol OrderStorePort: Sendable {
    func save(_ order: Order) async throws
}

/// The use case. It depends on the ports above, never on an adapter.
struct PlaceOrder: Sendable {
    let payments: any PaymentPort
    let store: any OrderStorePort

    func callAsFunction(id: String, itemPence: [Int]) async throws -> Order {
        guard !itemPence.isEmpty else { throw CheckoutError.emptyBasket }
        let total = itemPence.reduce(0, +)
        let receipt = try await payments.charge(pence: total, reference: id)
        let order = Order(id: id, totalPence: total, receipt: receipt)
        try await store.save(order)
        return order
    }
}

// MARK: Driven adapters: they import the core and implement its ports
struct FakeCardGateway: PaymentPort {
    let declinesOver: Int
    func charge(pence: Int, reference: String) async throws -> String {
        guard pence <= declinesOver else { throw CheckoutError.declined }
        return "rcpt-\(reference)"
    }
}

actor InMemoryOrderStore: OrderStorePort {
    private(set) var saved: [String] = []
    func save(_ order: Order) async throws { saved.append(order.id) }
}

// MARK: A driving adapter: here a script; in the app, a SwiftUI button or an App Intent
let store = InMemoryOrderStore()
let placeOrder = PlaceOrder(payments: FakeCardGateway(declinesOver: 5000), store: store)

for (id, items) in [("A12", [1200, 650]), ("A13", [4000, 3000]), ("A14", [])] {
    do {
        let order = try await placeOrder(id: id, itemPence: items)
        print("\(id): placed, \(order.totalPence)p, receipt \(order.receipt)")
    } catch {
        print("\(id): failed, \(error)")
    }
}
print("Saved:", await store.saved)
