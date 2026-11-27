// Generated from src/dsa/content/lessons/bs-on-answer/bsa-koko.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func finishes(_ piles: [Int], speed: Int, within h: Int) -> Bool {
    var hours = 0
    for pile in piles {
        hours += (pile + speed - 1) / speed
        if hours > h { return false }
    }
    return true
}

func minimumSpeed(_ piles: [Int], hours h: Int) -> (speed: Int, checks: Int) {
    var low = 1
    var high = piles.max()!
    var checks = 0
    while low < high {
        let mid = low + (high - low) / 2
        checks += 1
        if finishes(piles, speed: mid, within: h) { high = mid } else { low = mid + 1 }
    }
    return (low, checks)
}

let piles = [1_000_000_000, 999_999_999, 123_456_789]
print(minimumSpeed(piles, hours: 7))
print(minimumSpeed(piles, hours: 1_000_000_000))
