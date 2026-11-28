// Reference solution: The menu bill. Each lookup falls back to the special price with ??.
// O(n) time for n items (each dictionary lookup is O(1) on average), O(1) space.

public enum MenuBill {
    public static func total(for order: [String], prices: [String: Int], specialPrice: Int) -> Int {
        var total = 0
        for item in order {
            total += prices[item] ?? specialPrice
        }
        return total
    }
}
