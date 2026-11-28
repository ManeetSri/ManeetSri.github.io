// Reference solution: Rebuild the boarding-pass route. The tickets are the edges of a directed
// multigraph, and a route that uses each exactly once is an Euler path. Hierholzer's algorithm with an
// explicit stack: always fly the smallest unused ticket out of the airport on top of the stack; when
// an airport has none left, pop it onto the route. Airports are popped in reverse route order, so the
// route is reversed at the end. A dead end taken too early is simply popped first and ends up last.
// Each list is sorted largest first so `popLast()` takes the smallest in O(1).
// O(E log E) time for the sorting, O(E) for the walk, O(E) space.

public enum BoardingPassRoute {
    public static func itinerary(_ tickets: [[String]], from start: String) -> [String] {
        var departures: [String: [String]] = [:]
        for ticket in tickets {
            departures[ticket[0], default: []].append(ticket[1])
        }
        departures = departures.mapValues { $0.sorted(by: >) }

        var stack = [start]
        var route: [String] = []
        while let airport = stack.last {
            if let next = departures[airport]?.popLast() {
                stack.append(next)                     // fly the smallest unused ticket
            } else {
                route.append(stack.removeLast())       // stuck: this airport is final among those left
            }
        }
        return route.reversed()
    }
}
