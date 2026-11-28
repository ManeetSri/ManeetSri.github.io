// Generated from src/dsa/design/content/lessons/sd-swift-design/sd-swift-design-value-semantics.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

final class SharedCart {
    var pricesInPence: [Int] = []
    var discountPercent = 0
    var total: Int { pricesInPence.reduce(0, +) * (100 - discountPercent) / 100 }
}

struct Cart {
    var pricesInPence: [Int] = []
    var discountPercent = 0
    var total: Int { pricesInPence.reduce(0, +) * (100 - discountPercent) / 100 }
}

// The banner "tries" a code on the cart it was given
func preview(code percent: Int, on cart: SharedCart) -> Int {
    cart.discountPercent = percent
    return cart.total
}

func preview(code percent: Int, on cart: Cart) -> Int {
    var cart = cart
    cart.discountPercent = percent
    return cart.total
}

let shared = SharedCart()
shared.pricesInPence = [1200, 800]
print("Banner preview:", preview(code: 25, on: shared))
print("Checkout total:", shared.total)

let value = Cart(pricesInPence: [1200, 800])
print("Banner preview:", preview(code: 25, on: value))
print("Checkout total:", value.total)
