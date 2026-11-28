// Generated from src/dsa/content/lessons/two-pointers/tp-trapping-rain-water.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func trappedSlowly(_ heights: [Int]) -> Int {
    var total = 0
    for i in heights.indices {
        let tallestLeft = heights[...i].max()!
        let tallestRight = heights[i...].max()!
        total += min(tallestLeft, tallestRight) - heights[i]
    }
    return total
}

print(trappedSlowly([4, 1, 3, 0, 2, 5, 1, 2]))
