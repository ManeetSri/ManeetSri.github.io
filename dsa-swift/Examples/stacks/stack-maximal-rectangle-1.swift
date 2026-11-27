// Generated from src/dsa/content/lessons/stacks/stack-maximal-rectangle.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func largestArea(_ heights: [Int]) -> Int {
    var rising: [Int] = []
    var best = 0
    for i in 0...heights.count {
        let height = i < heights.count ? heights[i] : 0
        while let top = rising.last, heights[top] >= height {
            rising.removeLast()
            let left = rising.last ?? -1
            best = max(best, heights[top] * (i - left - 1))
        }
        rising.append(i)
    }
    return best
}

func largestRectangle(in grid: [[Int]]) -> Int {
    guard let width = grid.first?.count else {
        return 0
    }
    var heights = Array(repeating: 0, count: width)
    var best = 0
    for row in grid {
        for column in 0..<width {
            heights[column] = row[column] == 1 ? heights[column] + 1 : 0
        }
        print(heights)
        best = max(best, largestArea(heights))
    }
    return best
}

let grid = [
    [1, 0, 1, 0, 0],
    [1, 0, 1, 1, 1],
    [1, 1, 1, 1, 1],
    [1, 0, 0, 1, 0],
]
print("largest:", largestRectangle(in: grid))
