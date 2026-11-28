// Generated from src/dsa/content/lessons/interview-playbook/int-optimising.mdx. Edit the lesson, then run
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

func capacitySlow(_ weights: [Int], days: Int) -> Int {
    var capacity = weights.max()!
    while daysNeeded(weights, capacity: capacity) > days {
        capacity += 1
    }
    return capacity
}

func capacityFast(_ weights: [Int], days: Int) -> Int {
    var low = weights.max()!
    var high = weights.reduce(0, +)
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

let weights = [4, 8, 3, 7, 2, 6, 5]
print(capacitySlow(weights, days: 3), capacityFast(weights, days: 3))
