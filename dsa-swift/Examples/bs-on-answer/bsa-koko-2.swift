// Generated from src/dsa/content/lessons/bs-on-answer/bsa-koko.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func hoursNeeded(_ piles: [Int], speed: Int) -> Int {
    var hours = 0
    for pile in piles {
        hours += (pile + speed - 1) / speed
    }
    return hours
}

func minimumSpeed(_ piles: [Int], hours h: Int) -> Int {
    var low = 1
    var high = piles.max()!              // always fast enough, because h >= piles.count
    while low < high {
        let mid = low + (high - low) / 2
        let needed = hoursNeeded(piles, speed: mid)
        print("speed \(mid): \(needed) hours")
        if needed <= h {
            high = mid                   // fast enough: the answer is mid or slower
        } else {
            low = mid + 1                // too slow
        }
    }
    return low
}

print(minimumSpeed([5, 9, 4, 12], hours: 7))
