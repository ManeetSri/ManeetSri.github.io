// Generated from src/dsa/design/content/lessons/sd-behavioural-2/sd-behavioural-specification.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Specification<Candidate> {
    let name: String
    private let test: (Candidate) -> Bool

    init(_ name: String, _ test: @escaping (Candidate) -> Bool) {
        self.name = name
        self.test = test
    }

    func isSatisfied(by candidate: Candidate) -> Bool { test(candidate) }

    static func && (lhs: Self, rhs: Self) -> Self {
        Self("\(lhs.name) and \(rhs.name)") { lhs.test($0) && rhs.test($0) }
    }

    static func || (lhs: Self, rhs: Self) -> Self {
        Self("(\(lhs.name) or \(rhs.name))") { lhs.test($0) || rhs.test($0) }
    }

    static prefix func ! (spec: Self) -> Self {
        Self("not \(spec.name)") { !spec.test($0) }
    }
}

enum Status { case placed, packing, dispatched, delivered }

struct Order {
    let id: String
    let status: Status
    let minutesSincePlaced: Int
    let soldByMarketplaceSeller: Bool
}

// Small rules with names, then the business rule built from them
let notDispatched = Specification<Order>("not dispatched") { [.placed, .packing].contains($0.status) }
let placedRecently = Specification<Order>("placed within an hour") { $0.minutesSincePlaced <= 60 }
let soldByUs = !Specification<Order>("sold by a marketplace seller") { $0.soldByMarketplaceSeller }

let canCancelInApp = notDispatched && placedRecently && soldByUs
let needsSupport = notDispatched && !canCancelInApp

print("Rule:", canCancelInApp.name)

let orders = [
    Order(id: "A1", status: .placed, minutesSincePlaced: 12, soldByMarketplaceSeller: false),
    Order(id: "B2", status: .packing, minutesSincePlaced: 95, soldByMarketplaceSeller: false),
    Order(id: "C3", status: .placed, minutesSincePlaced: 5, soldByMarketplaceSeller: true),
    Order(id: "D4", status: .dispatched, minutesSincePlaced: 30, soldByMarketplaceSeller: false),
]

// The same rule drives the list filter, the button and the help text
print("Cancellable:", orders.filter(canCancelInApp.isSatisfied).map(\.id))
for order in orders {
    let action = canCancelInApp.isSatisfied(by: order) ? "Cancel order"
        : needsSupport.isSatisfied(by: order) ? "Contact support to cancel" : "Return it after delivery"
    print(order.id, "→", action)
}
