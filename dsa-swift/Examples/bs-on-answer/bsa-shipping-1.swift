// Generated from src/dsa/content/lessons/bs-on-answer/bsa-shipping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func dailyLoads(_ weights: [Int], capacity: Int) -> [[Int]] {
    var days: [[Int]] = [[]]
    var load = 0
    for weight in weights {
        if load + weight > capacity {        // doesn't fit: it goes tomorrow
            days.append([])
            load = 0
        }
        days[days.count - 1].append(weight)
        load += weight
    }
    return days
}

let weights = [6, 2, 9, 3, 5, 4, 8]
for capacity in [13, 16, 17, 20] {
    let days = dailyLoads(weights, capacity: capacity)
    print("capacity \(capacity): \(days.count) days \(days)")
}
