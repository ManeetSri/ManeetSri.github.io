// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-singleton-alternatives.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// A cart reached through a singleton: every "test" shares it
@MainActor
final class SharedCart {
    static let shared = SharedCart()
    private(set) var items: [String] = []
    func add(_ item: String) { items.append(item) }
}

@MainActor
func checkoutTotalWithSingleton() -> Int {
    SharedCart.shared.items.count * 5
}

@MainActor
func testEmptyCartCostsNothing() -> Bool {
    checkoutTotalWithSingleton() == 0
}

@MainActor
func testOneItemCostsFive() -> Bool {
    SharedCart.shared.add("Tea")
    return checkoutTotalWithSingleton() == 5
}

print("singleton, empty first:", testEmptyCartCostsNothing(), testOneItemCostsFive())
print("singleton, run again:", testOneItemCostsFive(), testEmptyCartCostsNothing())

// The same logic with the cart passed in: each test makes its own
final class Cart {
    private(set) var items: [String] = []
    func add(_ item: String) { items.append(item) }
}

func checkoutTotal(for cart: Cart) -> Int {
    cart.items.count * 5
}

func testEmptyCart() -> Bool {
    checkoutTotal(for: Cart()) == 0
}

func testOneItem() -> Bool {
    let cart = Cart()
    cart.add("Tea")
    return checkoutTotal(for: cart) == 5
}

print("injected, any order:", testOneItem(), testEmptyCart(), testOneItem(), testEmptyCart())
