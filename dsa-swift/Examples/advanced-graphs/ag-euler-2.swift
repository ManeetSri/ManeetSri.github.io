// Generated from src/dsa/content/lessons/advanced-graphs/ag-euler.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Hierholzer's algorithm on tickets: always fly the smallest unused ticket
func itinerary(_ tickets: [[String]], from start: String) -> [String] {
    var departures: [String: [String]] = [:]
    for ticket in tickets {
        departures[ticket[0], default: []].append(ticket[1])
    }
    departures = departures.mapValues { $0.sorted(by: >) }   // smallest last, for popLast()

    var stack = [start]
    var route: [String] = []
    while let airport = stack.last {
        if let next = departures[airport]?.popLast() {
            stack.append(next)
            print("fly \(airport) → \(next)    stack: \(stack.joined(separator: " "))")
        } else {
            route.append(stack.removeLast())
            print("stuck at \(airport)      route so far: \(route.joined(separator: " "))")
        }
    }
    return route.reversed()
}

let tickets = [["HUB", "ASH"], ["HUB", "CAL"], ["CAL", "HUB"]]
print(itinerary(tickets, from: "HUB"))
