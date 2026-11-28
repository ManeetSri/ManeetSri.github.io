// Generated from src/dsa/design/content/lessons/sd-coupling/sd-coupling-temporal.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Basket {
    var items: [String: Int]   // product ID → quantity
}

// Only the pricing service makes these, so holding one proves the basket was priced
struct PricedBasket {
    let basket: Basket
    let totalPence: Int
    let quoteID: String
    fileprivate init(basket: Basket, totalPence: Int, quoteID: String) {
        self.basket = basket
        self.totalPence = totalPence
        self.quoteID = quoteID
    }
}

struct Checkout {
    let prices: [String: Int]

    func price(_ basket: Basket) -> PricedBasket {
        let total = basket.items.reduce(0) { sum, item in sum + (prices[item.key] ?? 0) * item.value }
        return PricedBasket(basket: basket, totalPence: total, quoteID: "Q-\(total)")
    }

    // There's no placeOrder(_ basket: Basket): an unpriced basket has no way in
    func placeOrder(_ priced: PricedBasket) -> String {
        "Ordered for \(priced.totalPence)p under quote \(priced.quoteID)"
    }
}

let checkout = Checkout(prices: ["tea": 350, "mug": 900])
let priced = checkout.price(Basket(items: ["tea": 2, "mug": 1]))
print(checkout.placeOrder(priced))
