// Generated from src/dsa/content/lessons/two-pointers/tp-trapping-rain-water.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func trappedWithArrays(_ heights: [Int]) -> Int {
    let n = heights.count
    guard n > 0 else { return 0 }

    var leftMax = Array(repeating: 0, count: n)
    leftMax[0] = heights[0]
    for i in 1..<n {
        leftMax[i] = max(leftMax[i - 1], heights[i])
    }

    var rightMax = Array(repeating: 0, count: n)
    rightMax[n - 1] = heights[n - 1]
    for i in stride(from: n - 2, through: 0, by: -1) {
        rightMax[i] = max(rightMax[i + 1], heights[i])
    }

    var water: [Int] = []
    for i in 0..<n {
        water.append(min(leftMax[i], rightMax[i]) - heights[i])
    }
    print("leftMax: ", leftMax)
    print("rightMax:", rightMax)
    print("water:   ", water)
    return water.reduce(0, +)
}

print(trappedWithArrays([4, 1, 3, 0, 2, 5, 1, 2]))
