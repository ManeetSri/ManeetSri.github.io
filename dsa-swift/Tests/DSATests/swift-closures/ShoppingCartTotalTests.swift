import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ShoppingCartTotalTests {
    typealias Item = ShoppingCartTotal.Item

    @Test("Adds price times quantity for every item")
    func normalCart() {
        let cart = [
            Item(name: "Bread", pricePence: 145, quantity: 2),
            Item(name: "Milk", pricePence: 95, quantity: 1),
            Item(name: "Apples", pricePence: 30, quantity: 6),
        ]
        #expect(ShoppingCartTotal.total(of: cart) == 565)
    }

    @Test("A single item")
    func singleItem() {
        #expect(ShoppingCartTotal.total(of: [Item(name: "Tea", pricePence: 250, quantity: 1)]) == 250)
        #expect(ShoppingCartTotal.total(of: [Item(name: "Eggs", pricePence: 25, quantity: 12)]) == 300)
    }

    @Test("An empty cart costs nothing")
    func emptyCart() {
        #expect(ShoppingCartTotal.total(of: []) == 0)
    }

    @Test("Items with quantity 0 add nothing")
    func zeroQuantity() {
        let cart = [
            Item(name: "Cake", pricePence: 1_200, quantity: 0),
            Item(name: "Juice", pricePence: 180, quantity: 2),
        ]
        #expect(ShoppingCartTotal.total(of: cart) == 360)
    }

    @Test("Free items add nothing")
    func freeItems() {
        let cart = [
            Item(name: "Bag", pricePence: 0, quantity: 3),
            Item(name: "Rice", pricePence: 199, quantity: 1),
        ]
        #expect(ShoppingCartTotal.total(of: cart) == 199)
    }

    @Test("Handles the largest allowed cart")
    func largeCart() {
        let cart = (0..<1_000).map { Item(name: "Item \($0)", pricePence: 100_000, quantity: 1_000) }
        #expect(ShoppingCartTotal.total(of: cart) == 100_000_000_000)
    }
}
