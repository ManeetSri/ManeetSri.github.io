// Generated from src/dsa/content/lessons/binary-search/bs-other-searches.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var evaluations = 0
func profit(_ price: Int) -> Int {
    evaluations += 1
    return -(price - 6_180) * (price - 6_180)               // rises to a peak at 6,180, then falls
}

func ternaryPeak(_ low: Int, _ high: Int) -> Int {
    var low = low
    var high = high
    while low < high {
        let third = (high - low) / 3
        let m1 = low + third
        let m2 = high - third
        if profit(m1) < profit(m2) {
            low = m1 + 1                                     // m1 is on the way up
        } else {
            high = m2 - 1                                    // m2 is on the way down, or level with m1
        }
    }
    return low
}

func slopePeak(_ low: Int, _ high: Int) -> Int {
    var low = low
    var high = high
    while low < high {
        let mid = low + (high - low) / 2
        if profit(mid) < profit(mid + 1) {
            low = mid + 1                                    // uphill to the right
        } else {
            high = mid
        }
    }
    return low
}

evaluations = 0
print("ternary:", ternaryPeak(0, 10_000), "after", evaluations, "evaluations")
evaluations = 0
print("slope:", slopePeak(0, 10_000), "after", evaluations, "evaluations")
