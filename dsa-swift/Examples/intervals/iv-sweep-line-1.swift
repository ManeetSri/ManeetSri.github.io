// Generated from src/dsa/content/lessons/intervals/iv-sweep-line.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func busiestPeriod(_ intervals: [[Int]]) -> (count: Int, from: Int, to: Int) {
    var events: [(time: Int, change: Int)] = []
    for interval in intervals {
        events.append((interval[0], 1))
        events.append((interval[1], -1))
    }
    events.sort { ($0.time, $0.change) < ($1.time, $1.change) }   // half-open: ends first at a tie

    var active = 0
    var best = (count: 0, from: 0, to: 0)
    for (index, event) in events.enumerated() {
        active += event.change
        if active > best.count {
            best = (active, event.time, events[index + 1].time)  // holds until the next event
        }
    }
    return best
}

let sessions = [[1, 6], [2, 4], [3, 9], [5, 7], [8, 10]]
let busiest = busiestPeriod(sessions)
print("\(busiest.count) at once, during [\(busiest.from), \(busiest.to))")
