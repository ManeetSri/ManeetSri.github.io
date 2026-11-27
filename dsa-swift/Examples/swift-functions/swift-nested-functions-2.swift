// Generated from src/dsa/content/lessons/swift-functions/swift-nested-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countPeaks(in heights: [Int]) -> Int {
    // Positions outside the array count as height 0
    func height(at index: Int) -> Int {
        if index < 0 || index >= heights.count {
            return 0
        }
        return heights[index]
    }

    var peaks = 0
    for index in 0..<heights.count {
        let current = heights[index]
        if current > height(at: index - 1) && current > height(at: index + 1) {
            peaks += 1
        }
    }
    return peaks
}

print(countPeaks(in: [1, 3, 2, 5, 4]))
print(countPeaks(in: [4, 1, 1, 2]))
print(countPeaks(in: []))
