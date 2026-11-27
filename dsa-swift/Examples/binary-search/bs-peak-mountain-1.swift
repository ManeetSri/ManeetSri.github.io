// Generated from src/dsa/content/lessons/binary-search/bs-peak-mountain.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func peakIndex(_ heights: [Int]) -> Int {
    var low = 0
    var high = heights.count - 1
    while low < high {
        let mid = low + (high - low) / 2       // mid < high, so mid + 1 is a real index
        print("  [\(low), \(high)], mid \(mid): \(heights[mid]) vs \(heights[mid + 1])")
        if heights[mid] < heights[mid + 1] {
            low = mid + 1                      // uphill to the right
        } else {
            high = mid                         // downhill: mid could be the peak
        }
    }
    return low
}

let profile = [1, 3, 2, 4, 7, 6, 5]
let peak = peakIndex(profile)
print("peak at \(peak), height \(profile[peak])")
print(peakIndex([1, 2, 3, 4, 5]), peakIndex([5, 4, 3, 2, 1]))
