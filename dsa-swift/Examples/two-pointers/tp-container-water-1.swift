// Generated from src/dsa/content/lessons/two-pointers/tp-container-water.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func mostWaterSlowly(_ heights: [Int]) -> Int {
    var best = 0
    for i in heights.indices {
        for j in (i + 1)..<heights.count {
            best = max(best, min(heights[i], heights[j]) * (j - i))
        }
    }
    return best
}

print(mostWaterSlowly([3, 7, 2, 5, 4, 8, 3, 6]))
