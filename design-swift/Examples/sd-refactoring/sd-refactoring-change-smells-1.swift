// Generated from src/dsa/design/content/lessons/sd-refactoring/sd-refactoring-change-smells.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct DiscountCode {
    let percentOff: Int
}

struct Line {
    let unitPrice: Int
    let quantity: Int
}

struct Cart {
    var lines: [Line]
    var discount: DiscountCode?
    var deliveryFee = 399
    var freeDeliveryFrom = 5000

    // Moved here from the view model: the cart's data, so the cart's rule
    var subtotal: Int {
        lines.reduce(0) { $0 + $1.unitPrice * $1.quantity }
    }

    var total: Int {
        let discounted = subtotal - subtotal * (discount?.percentOff ?? 0) / 100
        return discounted >= freeDeliveryFrom ? discounted : discounted + deliveryFee
    }
}

// What's left is presentation: it uses the cart's answer instead of recomputing it
struct CartSummaryViewModel {
    let cart: Cart

    var totalText: String {
        let pence = cart.total % 100
        return "Total: £\(cart.total / 100).\(pence < 10 ? "0" : "")\(pence)"
    }
}

let small = Cart(lines: [Line(unitPrice: 1250, quantity: 2)])
let large = Cart(lines: [Line(unitPrice: 2000, quantity: 3)], discount: DiscountCode(percentOff: 10))
print(CartSummaryViewModel(cart: small).totalText)
print(CartSummaryViewModel(cart: large).totalText)
