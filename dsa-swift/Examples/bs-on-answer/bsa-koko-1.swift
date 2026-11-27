// Generated from src/dsa/content/lessons/bs-on-answer/bsa-koko.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func hoursNeeded(_ piles: [Int], speed: Int) -> Int {
    var hours = 0
    for pile in piles {
        hours += (pile + speed - 1) / speed      // ⌈pile / speed⌉
    }
    return hours
}

let piles = [5, 9, 4, 12]
for speed in 1...7 {
    print("speed \(speed): \(hoursNeeded(piles, speed: speed)) hours")
}
