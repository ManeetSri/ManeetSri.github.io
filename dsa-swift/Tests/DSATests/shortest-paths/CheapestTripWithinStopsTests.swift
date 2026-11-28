import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct TripRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct CheapestTripWithinStopsTests {
    /// Tries every sequence of at most maxStops + 1 flights. Exponential, so only for tiny inputs.
    private func bruteForce(_ flights: [[Int]], _ source: Int, _ target: Int, _ maxStops: Int) -> Int {
        var best = Int.max
        func explore(_ city: Int, _ price: Int, _ flightsLeft: Int) {
            if city == target { best = min(best, price) }
            guard flightsLeft > 0 else { return }
            for flight in flights where flight[0] == city {
                explore(flight[1], price + flight[2], flightsLeft - 1)
            }
        }
        explore(source, 0, maxStops + 1)
        return best == Int.max ? -1 : best
    }

    private let example = [[0, 1, 10], [1, 3, 10], [0, 2, 5], [2, 1, 2], [0, 3, 40]]

    @Test("Examples", arguments: [(0, 40), (1, 20), (2, 17), (5, 17)])
    func examples(maxStops: Int, expected: Int) {
        #expect(CheapestTripWithinStops.cheapestPrice(cityCount: 4, flights: example, from: 0, to: 3, maxStops: maxStops) == expected)
    }

    @Test("The cheap way in uses up the stops")
    func cheapWayInIsTooLong() {
        let flights = [[0, 1, 1], [1, 2, 1], [0, 2, 5], [2, 3, 1]]
        #expect(CheapestTripWithinStops.cheapestPrice(cityCount: 4, flights: flights, from: 0, to: 3, maxStops: 0) == -1)
        #expect(CheapestTripWithinStops.cheapestPrice(cityCount: 4, flights: flights, from: 0, to: 3, maxStops: 1) == 6)
        #expect(CheapestTripWithinStops.cheapestPrice(cityCount: 4, flights: flights, from: 0, to: 3, maxStops: 2) == 3)
    }

    @Test("Edge cases")
    func edgeCases() {
        // Already there: no flights needed
        #expect(CheapestTripWithinStops.cheapestPrice(cityCount: 3, flights: [[0, 1, 5]], from: 2, to: 2, maxStops: 0) == 0)
        // Flights are one way
        #expect(CheapestTripWithinStops.cheapestPrice(cityCount: 2, flights: [[0, 1, 5]], from: 1, to: 0, maxStops: 3) == -1)
        // No flights at all
        #expect(CheapestTripWithinStops.cheapestPrice(cityCount: 2, flights: [], from: 0, to: 1, maxStops: 1) == -1)
        // Parallel flights: the cheaper one counts
        #expect(CheapestTripWithinStops.cheapestPrice(cityCount: 2, flights: [[0, 1, 9], [0, 1, 4]], from: 0, to: 1, maxStops: 0) == 4)
        // A loop back through the start never helps
        #expect(CheapestTripWithinStops.cheapestPrice(cityCount: 3, flights: [[0, 1, 2], [1, 0, 1], [1, 2, 3]], from: 0, to: 2, maxStops: 4) == 5)
    }

    @Test("Matches brute force on 500 small random networks")
    func randomSmall() {
        var random = TripRandom(seed: 7)
        for _ in 0..<500 {
            let n = Int.random(in: 2...6, using: &random)
            let flights = (0..<Int.random(in: 0...12, using: &random)).compactMap { _ -> [Int]? in
                let a = Int.random(in: 0..<n, using: &random), b = Int.random(in: 0..<n, using: &random)
                return a == b ? nil : [a, b, Int.random(in: 1...30, using: &random)]
            }
            let source = Int.random(in: 0..<n, using: &random)
            let target = Int.random(in: 0..<n, using: &random)
            let maxStops = Int.random(in: 0...3, using: &random)
            #expect(CheapestTripWithinStops.cheapestPrice(cityCount: n, flights: flights, from: source, to: target, maxStops: maxStops)
                == bruteForce(flights, source, target, maxStops))
        }
    }

    @Test("2,000 cities and 20,000 flights", arguments: [(0, 4_000), (1, 3_991), (99, 3_109), (250, 1_750), (398, 418), (399, 400), (1_998, 400)])
    func large(maxStops: Int, expected: Int) {
        // A chain 0 → 1 → … → 400 at price 1 per flight, and an express flight from 0 to chain city j
        // for 10 · j. With f = maxStops + 1 flights, the best trip takes the express to the first city
        // that leaves enough flights for the rest of the chain. Thousands of overpriced flights between
        // the other cities can never help.
        var random = TripRandom(seed: 99)
        let chainLength = 400
        var flights: [[Int]] = (0..<chainLength).map { [$0, $0 + 1, 1] }
        flights += (1...chainLength).map { [0, $0, 10 * $0] }
        while flights.count < 20_000 {
            let a = Int.random(in: 0..<2_000, using: &random), b = Int.random(in: 1..<2_000, using: &random)
            if a != b { flights.append([a, b, 1_000_000 + Int.random(in: 0...1_000, using: &random)]) }
        }
        flights.shuffle(using: &random)
        #expect(CheapestTripWithinStops.cheapestPrice(cityCount: 2_000, flights: flights, from: 0, to: chainLength, maxStops: maxStops) == expected)
    }
}
