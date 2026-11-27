// Reference solution: The most items with a half-price voucher. For any count k, the cheapest basket
// of k items is the k cheapest, with the voucher on the dearest of them: swapping any item for a
// cheaper one, or moving the voucher to a dearer item in the basket, never costs more. So sort, and
// grow the basket from the cheapest. That cost only rises as k grows (each new item adds at least
// half its price), so stop at the first k that doesn't fit. O(n log n) time for the sort, O(n) space.

public enum VoucherShoppingBasket {
    public static func mostItems(_ prices: [Int], budget: Int) -> Int {
        var total = 0                                    // full price of the k cheapest items
        var best = 0
        for (index, price) in prices.sorted().enumerated() {
            total += price
            if total - price / 2 > budget { break }      // the voucher saves half of the dearest, rounded down
            best = index + 1
        }
        return best
    }
}
