// Generated from src/dsa/content/lessons/bs-on-answer/bsa-shipping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func daysNeeded(_ weights: [Int], capacity: Int) -> Int {
    var days = 1
    var load = 0
    for weight in weights {
        if load + weight > capacity {
            days += 1
            load = 0
        }
        load += weight
    }
    return days
}

func shipWithin(_ weights: [Int], days: Int) -> Int {
    var low = weights.max()!                 // anything less can't carry the heaviest package
    var high = weights.reduce(0, +)          // one day carries everything
    while low < high {
        let mid = low + (high - low) / 2
        if daysNeeded(weights, capacity: mid) <= days {
            high = mid
        } else {
            low = mid + 1
        }
    }
    return low
}

let weights = [6, 2, 9, 3, 5, 4, 8]
for days in 1...7 {
    print("days \(days): capacity \(shipWithin(weights, days: days))")
}
