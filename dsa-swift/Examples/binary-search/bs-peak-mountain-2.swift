// Generated from src/dsa/content/lessons/binary-search/bs-peak-mountain.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func summit(_ heights: [Int]) -> Int {
    var low = 0
    var high = heights.count - 1
    while low < high {
        let mid = low + (high - low) / 2
        if heights[mid] < heights[mid + 1] { low = mid + 1 } else { high = mid }
    }
    return low
}

func search(_ heights: [Int], for target: Int, in range: ClosedRange<Int>, rising: Bool) -> Int? {
    var low = range.lowerBound
    var high = range.upperBound
    while low <= high {
        let mid = low + (high - low) / 2
        if heights[mid] == target {
            return mid
        }
        let goRight = rising ? heights[mid] < target : heights[mid] > target
        if goRight { low = mid + 1 } else { high = mid - 1 }
    }
    return nil
}

func find(_ target: Int, inMountain heights: [Int]) -> Int? {
    let top = summit(heights)
    if let index = search(heights, for: target, in: 0...top, rising: true) {
        return index
    }
    guard top + 1 < heights.count else { return nil }
    return search(heights, for: target, in: (top + 1)...(heights.count - 1), rising: false)
}

let trail = [120, 340, 560, 910, 780, 560, 230]
print("summit at", summit(trail))
print(find(560, inMountain: trail) as Any, find(230, inMountain: trail) as Any, find(600, inMountain: trail) as Any)
