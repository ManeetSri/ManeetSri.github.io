// Reference solution: Cheapest trip within k stops. At most k stops means at most k + 1 flights, and
// Bellman–Ford's round i finds every cheapest trip that uses at most i flights, provided each round
// reads prices from a copy taken at its start (in place, one round could chain several flights).
// Run k + 1 rounds. O((k + 1) · (n + m)) time, O(n) space.

public enum CheapestTripWithinStops {
    public static func cheapestPrice(cityCount: Int, flights: [[Int]], from source: Int, to target: Int, maxStops: Int) -> Int {
        let unreached = Int.max
        var price = Array(repeating: unreached, count: cityCount)
        price[source] = 0
        for _ in 0...maxStops {
            let before = price                          // prices using one flight fewer
            var changed = false
            for flight in flights where before[flight[0]] != unreached {
                let candidate = before[flight[0]] + flight[2]
                if candidate < price[flight[1]] {
                    price[flight[1]] = candidate
                    changed = true
                }
            }
            if !changed { break }                       // more flights can't help any further
        }
        return price[target] == unreached ? -1 : price[target]
    }
}
