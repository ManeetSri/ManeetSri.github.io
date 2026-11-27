// Generated from src/dsa/content/lessons/divide-conquer/dc-max-subarray.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The best run that crosses the middle: the best run ending at mid - 1 plus the best run starting at mid
func crossingSum(_ numbers: [Int], _ low: Int, _ mid: Int, _ high: Int) -> Int {
    var sum = 0
    var bestLeft = numbers[mid - 1]
    for index in stride(from: mid - 1, through: low, by: -1) {   // grow leftwards from the middle
        sum += numbers[index]
        bestLeft = max(bestLeft, sum)
    }
    sum = 0
    var bestRight = numbers[mid]
    for index in mid..<high {                                    // grow rightwards from the middle
        sum += numbers[index]
        bestRight = max(bestRight, sum)
    }
    return bestLeft + bestRight
}

func bestSum(_ numbers: [Int], _ low: Int, _ high: Int) -> Int {
    if high - low == 1 {
        return numbers[low]                     // one element: the only run is itself
    }
    let mid = low + (high - low) / 2
    let left = bestSum(numbers, low, mid)
    let right = bestSum(numbers, mid, high)
    let crossing = crossingSum(numbers, low, mid, high)
    let best = max(left, right, crossing)
    print("\(Array(numbers[low..<high])): left \(left), right \(right), crossing \(crossing) → \(best)")
    return best
}

let numbers = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
print("answer:", bestSum(numbers, 0, numbers.count))
