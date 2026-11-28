// Generated from src/dsa/content/lessons/stacks/stack-histogram.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func largestArea(_ heights: [Int]) -> Int {
    var rising: [Int] = []                        // bar indexes, heights increasing bottom to top
    var best = 0
    for i in 0...heights.count {
        let height = i < heights.count ? heights[i] : 0     // a sentinel bar of height 0 at the end
        while let top = rising.last, heights[top] >= height {
            rising.removeLast()
            let left = rising.last ?? -1          // the previous shorter bar
            let width = i - left - 1              // bar i is the next shorter bar
            best = max(best, heights[top] * width)
        }
        rising.append(i)
    }
    return best
}

for heights in [[2, 1, 5, 6, 2, 3], [3, 3, 3], [1, 2, 3, 4, 5], [6, 2, 5, 4, 5, 1, 6], [], [7]] {
    print(heights, largestArea(heights))
}
