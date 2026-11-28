// Generated from src/dsa/design/content/lessons/sd-solid/sd-solid-srp.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Line {
    let name: String
    let pence: Int
}

struct Order {
    let id: String
    let lines: [Line]
    let deliveryPence: Int
}

// Finance owns this: what the customer owes, and the VAT included in it
struct ReceiptCalculator {
    func total(for order: Order) -> Int {
        order.lines.reduce(0) { $0 + $1.pence } + order.deliveryPence
    }

    func vat(includedIn total: Int) -> Int {
        total / 6    // 20% VAT is a sixth of a VAT-inclusive price
    }
}

// Design owns this: how an amount looks
struct MoneyFormatter {
    func string(pence: Int) -> String {
        "£\(pence / 100)." + (pence % 100 < 10 ? "0" : "") + "\(pence % 100)"
    }
}

// Support owns this: the wording people paste into emails
struct ShareTextComposer {
    let calculator = ReceiptCalculator()
    let money = MoneyFormatter()

    func text(for order: Order) -> String {
        let total = calculator.total(for: order)
        let vat = calculator.vat(includedIn: total)
        return "Order \(order.id): \(order.lines.count) items, \(money.string(pence: total)) including \(money.string(pence: vat)) VAT"
    }
}

let order = Order(id: "A1029", lines: [Line(name: "Sourdough", pence: 450), Line(name: "Olive oil", pence: 899), Line(name: "Coffee", pence: 1_250)], deliveryPence: 149)
let calculator = ReceiptCalculator()
let total = calculator.total(for: order)
print("Total:", MoneyFormatter().string(pence: total))
print("VAT included:", MoneyFormatter().string(pence: calculator.vat(includedIn: total)))
print(ShareTextComposer().text(for: order))
