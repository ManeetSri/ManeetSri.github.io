// Reference solution: Where to build the depot. The cheapest spot is the lower weighted median: the first
// position p with 2 × weight(at or before p) ≥ total. Find it like quickselect, steering by weight: pick a
// random pivot position, partition three ways, and keep the side that holds the answer, tracking the
// weight already discarded on the left. Equal positions leave in one round. O(n) expected time.

public enum WeightedMedianDepot {
    public static func bestSpot(positions: [Int], weights: [Int], using generator: inout some RandomNumberGenerator) -> (spot: Int, cost: Int) {
        let total = weights.reduce(0, +)
        var shops = Array(zip(positions, weights))     // the current range: (position, weight)
        var weightBefore = 0                           // weight of every shop left of the range
        var spot = positions[0]
        while !shops.isEmpty {
            let pivot = shops[Int.random(in: 0..<shops.count, using: &generator)].0
            var less: [(Int, Int)] = []
            var greater: [(Int, Int)] = []
            var lessWeight = 0
            var equalWeight = 0
            for shop in shops {
                if shop.0 < pivot {
                    less.append(shop)
                    lessWeight += shop.1
                } else if shop.0 > pivot {
                    greater.append(shop)
                } else {
                    equalWeight += shop.1
                }
            }
            if 2 * (weightBefore + lessWeight) >= total {
                shops = less                           // half the weight is reached before the pivot
            } else if 2 * (weightBefore + lessWeight + equalWeight) >= total {
                spot = pivot
                break
            } else {
                weightBefore += lessWeight + equalWeight
                shops = greater
            }
        }
        let cost = zip(positions, weights).reduce(0) { $0 + $1.1 * abs($1.0 - spot) }
        return (spot, cost)
    }
}
