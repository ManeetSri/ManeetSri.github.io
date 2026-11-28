// Generated from src/dsa/content/lessons/design-structures/ds-hit-counter.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The versions of one key, sorted by time because times only ever increase
let theme: [(time: Int, value: String)] = [(10, "light"), (20, "dark"), (35, "sepia")]

/// The value at the latest time ≤ t: one step before the first version later than t.
func value(in history: [(time: Int, value: String)], at time: Int) -> String? {
    var low = 0
    var high = history.count                // half-open: the first later version is in low...high
    while low < high {
        let middle = low + (high - low) / 2
        if history[middle].time <= time {
            low = middle + 1                // middle isn't later than t: look right
        } else {
            high = middle                   // middle is later: it might be the first such
        }
    }
    return low == 0 ? nil : history[low - 1].value
}

for t in [5, 10, 19, 20, 34, 35, 1_000] {
    print(t, value(in: theme, at: t) ?? "nil")
}
