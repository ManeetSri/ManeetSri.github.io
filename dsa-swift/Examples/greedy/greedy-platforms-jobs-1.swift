// Generated from src/dsa/content/lessons/greedy/greedy-platforms-jobs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Trains occupy a platform from arrival to departure, both minutes included (times are HHMM)
func platformsNeeded(arrivals: [Int], departures: [Int], sameMinuteFrees: Bool) -> Int {
    let arrive = arrivals.sorted()
    let depart = departures.sorted()
    var inUse = 0
    var most = 0
    var d = 0                                          // the next departure to process
    for time in arrive {
        // A platform is free once its train has left: strictly before, if the minute is shared
        while d < depart.count && (depart[d] < time || (sameMinuteFrees && depart[d] == time)) {
            inUse -= 1
            d += 1
        }
        inUse += 1
        most = max(most, inUse)
    }
    return most
}

let arrivals = [905, 910, 915, 945, 1000, 1030]
let departures = [1000, 915, 930, 1010, 1005, 1100]
print("platforms:", platformsNeeded(arrivals: arrivals, departures: departures, sameMinuteFrees: false))
print("if a departure freed the platform for the same minute:", platformsNeeded(arrivals: arrivals, departures: departures, sameMinuteFrees: true))
