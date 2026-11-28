// Reference solution: Shopping cart total. One reduce over the items, O(n) time, O(1) extra space.

public enum ShoppingCartTotal {
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

    public static func total(of items: [Item]) -> Int {
        items.reduce(0) { total, item in total + item.pricePence * item.quantity }
    }
}
