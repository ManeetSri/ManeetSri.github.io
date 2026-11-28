// Generated from src/dsa/design/content/lessons/sd-principles/sd-principles-grasp-balance.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// Domain: the rules, and nothing about storage
struct Order: Codable, Equatable {
    enum Status: String, Codable {
        case placed, shipped, cancelled
    }

    let id: String
    private(set) var status: Status

    init(id: String, status: Status = .placed) {
        self.id = id
        self.status = status
    }

    var canBeCancelled: Bool { status == .placed }

    mutating func cancel() throws(OrderError) {
        guard canBeCancelled else { throw .cannotCancel(status.rawValue) }
        status = .cancelled
    }
}

enum OrderError: Error {
    case cannotCancel(String)
    case notFound(String)
}

// Pure fabrication: it exists to keep Order cohesive and uncoupled
protocol OrderStore {
    func load(id: String) throws -> Order?
    func save(_ order: Order) throws
}

final class InMemoryOrderStore: OrderStore {
    private var rows: [String: Data] = [:]
    private let encoder = JSONEncoder()

    init() {
        encoder.outputFormatting = .sortedKeys
    }

    func load(id: String) throws -> Order? {
        guard let data = rows[id] else { return nil }
        return try JSONDecoder().decode(Order.self, from: data)
    }

    func save(_ order: Order) throws {
        rows[order.id] = try encoder.encode(order)
    }

    func storedJSON(id: String) -> String {
        String(decoding: rows[id] ?? Data(), as: UTF8.self)
    }
}

// The use case's controller coordinates the rule and the storage
struct CancelOrder {
    let store: any OrderStore

    func run(id: String) throws -> Order {
        guard var order = try store.load(id: id) else { throw OrderError.notFound(id) }
        try order.cancel()
        try store.save(order)
        return order
    }
}

let store = InMemoryOrderStore()
try store.save(Order(id: "A1"))
try store.save(Order(id: "B2", status: .shipped))

let cancelOrder = CancelOrder(store: store)
for id in ["A1", "B2", "C3"] {
    do {
        let order = try cancelOrder.run(id: id)
        print("\(id): \(order.status)")
    } catch {
        print("\(id): \(error)")
    }
}
print("A1 is stored as \(store.storedJSON(id: "A1"))")
