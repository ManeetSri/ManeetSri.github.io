import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private struct RouteRandom {
    var state: UInt64
    mutating func next(_ bound: Int) -> Int {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int((state >> 33) % UInt64(bound))
    }
}

@Suite struct BoardingPassRouteTests {
    /// True when `route` starts at `start` and uses every ticket exactly once.
    private func usesEveryTicket(_ route: [String], _ tickets: [[String]], from start: String) -> Bool {
        guard route.first == start, route.count == tickets.count + 1 else { return false }
        let flown = zip(route, route.dropFirst()).map { "\($0)>\($1)" }.sorted()
        return flown == tickets.map { "\($0[0])>\($0[1])" }.sorted()
    }

    /// Backtracking over every route, trying tickets in alphabetical order: the first complete route
    /// found is the smallest. Exponential, so only for a handful of tickets.
    private func bruteForce(_ tickets: [[String]], from start: String) -> [String] {
        let sorted = tickets.sorted { ($0[0], $0[1]) < ($1[0], $1[1]) }
        var used = [Bool](repeating: false, count: sorted.count)
        var route = [start]
        func extend() -> Bool {
            if route.count == sorted.count + 1 { return true }
            for (i, ticket) in sorted.enumerated() where !used[i] && ticket[0] == route.last! {
                used[i] = true
                route.append(ticket[1])
                if extend() { return true }
                route.removeLast()
                used[i] = false
            }
            return false
        }
        _ = extend()
        return route
    }

    @Test("Small trips", arguments: [
        ([["DOV", "ASH"], ["ASH", "CAL"], ["CAL", "DOV"], ["DOV", "BRY"]], "DOV", ["DOV", "ASH", "CAL", "DOV", "BRY"]),
        ([["HUB", "ASH"], ["HUB", "CAL"], ["CAL", "HUB"]], "HUB", ["HUB", "CAL", "HUB", "ASH"]),
        ([["ASH", "BRY"], ["BRY", "ASH"], ["ASH", "BRY"]], "ASH", ["ASH", "BRY", "ASH", "BRY"]),
        ([["ELM", "FEN"]], "ELM", ["ELM", "FEN"]),
        ([["COR", "ASH"], ["ASH", "COR"], ["COR", "BRY"], ["BRY", "COR"]], "COR", ["COR", "ASH", "COR", "BRY", "COR"]),
    ] as [([[String]], String, [String])])
    func smallTrips(tickets: [[String]], start: String, expected: [String]) {
        #expect(BoardingPassRoute.itinerary(tickets, from: start) == expected)
    }

    @Test("A dead end that must come last")
    func deadEndLast() {
        let tickets = [["KEW", "AYR"], ["AYR", "BUD"], ["BUD", "KEW"], ["KEW", "BUD"], ["BUD", "AYR"]]
        // Always taking the smallest ticket gives KEW→AYR→BUD→AYR and strands BUD→KEW and KEW→BUD
        let route = BoardingPassRoute.itinerary(tickets, from: "KEW")
        #expect(route == ["KEW", "AYR", "BUD", "KEW", "BUD", "AYR"])
        #expect(usesEveryTicket(route, tickets, from: "KEW"))
    }

    @Test("No tickets: the route is just the start")
    func noTickets() {
        #expect(BoardingPassRoute.itinerary([], from: "ASH") == ["ASH"])
    }

    @Test("Matches brute force on 300 random trips")
    func randomSmall() {
        let airports = ["ASH", "BRY", "CAL", "DOV", "ELM"]
        var random = RouteRandom(state: 9)
        for _ in 0..<300 {
            // A random walk is itself a valid route, so a route always exists. Shuffle its tickets.
            let start = airports[random.next(airports.count)]
            var walk = [start]
            for _ in 0..<(1 + random.next(8)) {
                var next = airports[random.next(airports.count)]
                while next == walk.last! { next = airports[random.next(airports.count)] }
                walk.append(next)
            }
            var tickets = zip(walk, walk.dropFirst()).map { [$0, $1] }
            for i in stride(from: tickets.count - 1, to: 0, by: -1) {
                tickets.swapAt(i, random.next(i + 1))
            }
            let route = BoardingPassRoute.itinerary(tickets, from: start)
            #expect(route == bruteForce(tickets, from: start))
        }
    }

    @Test("10,000 round trips from a hub, plus a dead end (needs an iterative DFS)")
    func manyRoundTrips() {
        // HUB→AAA is the smallest ticket out of HUB but strands everything else, so it must be last
        func name(_ i: Int) -> String {
            let digits = String(i)
            return "X" + String(repeating: "0", count: 5 - digits.count) + digits
        }
        var tickets = [["HUB", "AAA"]]
        var expected = ["HUB"]
        for i in 0..<10_000 {
            tickets.append(["HUB", name(i)])
            tickets.append([name(i), "HUB"])
            expected += [name(i), "HUB"]
        }
        expected.append("AAA")
        tickets.reverse()
        #expect(BoardingPassRoute.itinerary(tickets, from: "HUB") == expected)
    }
}
