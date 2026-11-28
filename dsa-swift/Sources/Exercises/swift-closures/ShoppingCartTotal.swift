// Problem: Shopping cart total (M06 · map, filter and reduce)

public enum ShoppingCartTotal {
    /// One line of a shopping cart: a product, its price in pence and how many are being bought.
    public struct Item: Equatable {
        public let name: String
        public let pricePence: Int
        public let quantity: Int

        public init(name: String, pricePence: Int, quantity: Int) {
            self.name = name
            self.pricePence = pricePence
            self.quantity = quantity
        }
    }

    /// Returns the cost of the whole cart in pence: each item's price times its quantity, added up.
    public static func total(of items: [Item]) -> Int {
        // Write your solution here, then run:
        // swift test --filter ShoppingCartTotalTests
        return 0
    }
}
