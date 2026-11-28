// Reference solution: Cut a rod for the best price. An unbounded knapsack: each offered length is an
// item with weight = length and value = price, available any number of times, and unsold rod is waste,
// so best[w] (the most from w units of rod) starts at 0 everywhere. Offers are processed one at a time
// with the room loop left to right, so an offer can be used again. O(length · offers) time,
// O(length) space.

public enum RodCutForProfit {
    public static func bestPrice(length: Int, offers: [[Int]]) -> Int {
        var best = Array(repeating: 0, count: length + 1)
        for offer in offers where offer[0] <= length {
            let piece = offer[0]
            let price = offer[1]
            for w in stride(from: piece, through: length, by: 1) {    // left to right: reuse allowed
                best[w] = max(best[w], best[w - piece] + price)
            }
        }
        return best[length]
    }
}
