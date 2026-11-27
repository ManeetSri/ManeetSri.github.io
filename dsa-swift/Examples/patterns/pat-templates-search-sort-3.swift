// Generated from src/dsa/content/lessons/patterns/pat-templates-search-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Binary search on the answer: the smallest value that works, and the largest value that works

// Smallest daily capacity that ships every parcel, in order, within `days` days
func smallestCapacity(_ weights: [Int], days: Int) -> Int {
    func works(_ capacity: Int) -> Bool {         // greedy check: fill each day as far as it goes
        var used = 1
        var load = 0
        for weight in weights {
            if load + weight > capacity {
                used += 1
                load = 0
            }
            load += weight
        }
        return used <= days
    }
    var low = weights.max()!                      // smaller can't carry the heaviest parcel
    var high = weights.reduce(0, +)               // one day carries everything
    while low < high {
        let mid = low + (high - low) / 2
        if works(mid) { high = mid } else { low = mid + 1 }
    }
    return low
}

// Largest minimum gap when placing `count` sensors at some of the sorted positions
func largestGap(_ positions: [Int], count: Int) -> Int {
    func works(_ gap: Int) -> Bool {              // greedy check: place each sensor as early as allowed
        var placed = 1
        var last = positions[0]
        for position in positions.dropFirst() where position - last >= gap {
            placed += 1
            last = position
        }
        return placed >= count
    }
    var low = 0                                   // a gap of 0 always works
    var high = positions[positions.count - 1] - positions[0]
    while low < high {
        let mid = low + (high - low + 1) / 2      // round up, or low = mid could loop forever
        if works(mid) { low = mid } else { high = mid - 1 }
    }
    return low
}

print(smallestCapacity([4, 8, 2, 6, 5, 3, 7], days: 3))
print(largestGap([1, 2, 4, 8, 9], count: 3))
