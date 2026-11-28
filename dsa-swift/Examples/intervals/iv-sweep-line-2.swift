// Generated from src/dsa/content/lessons/intervals/iv-sweep-line.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Each trip is [passengers, from, to]: they board at stop `from` and leave at stop `to`
func fitsWithEvents(_ trips: [[Int]], capacity: Int) -> Bool {
    var events: [(stop: Int, change: Int)] = []
    for trip in trips {
        events.append((trip[1], trip[0]))       // board
        events.append((trip[2], -trip[0]))      // leave
    }
    events.sort { ($0.stop, $0.change) < ($1.stop, $1.change) }   // at a stop, riders leave first
    var onBoard = 0
    for event in events {
        onBoard += event.change
        if onBoard > capacity { return false }
    }
    return true
}

func fitsWithDifferenceArray(_ trips: [[Int]], capacity: Int, lastStop: Int) -> Bool {
    var diff = Array(repeating: 0, count: lastStop + 1)
    for trip in trips {
        diff[trip[1]] += trip[0]
        diff[trip[2]] -= trip[0]                // half-open: gone by stop `to`
    }
    var onBoard = 0
    for change in diff {
        onBoard += change
        if onBoard > capacity { return false }
    }
    return true
}

let trips = [[3, 0, 4], [2, 2, 6], [4, 4, 8]]
for capacity in [5, 6] {
    print(capacity, fitsWithEvents(trips, capacity: capacity),
          fitsWithDifferenceArray(trips, capacity: capacity, lastStop: 8))
}
