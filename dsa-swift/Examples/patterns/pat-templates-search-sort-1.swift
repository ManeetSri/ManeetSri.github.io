// Generated from src/dsa/content/lessons/patterns/pat-templates-search-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Lower and upper bound on a half-open range, and what they give you
func lowerBound(_ items: [Int], _ target: Int) -> Int {
    var low = 0
    var high = items.count                        // the answer is somewhere in low...high
    while low < high {
        let mid = low + (high - low) / 2
        if items[mid] < target {
            low = mid + 1                         // mid and everything before it is too small
        } else {
            high = mid                            // mid might be the answer; keep it
        }
    }
    return low                                    // the first index with items[index] >= target
}

func upperBound(_ items: [Int], _ target: Int) -> Int {
    var low = 0
    var high = items.count
    while low < high {
        let mid = low + (high - low) / 2
        if items[mid] <= target { low = mid + 1 } else { high = mid }
    }
    return low                                    // the first index with items[index] > target
}

let scores = [10, 20, 20, 20, 35, 40, 40, 55]
let first = lowerBound(scores, 20)
let last = upperBound(scores, 20) - 1
print("20 appears at \(first)...\(last)")
let at30 = lowerBound(scores, 30)
print("30 present?", at30 < scores.count && scores[at30] == 30)
print("scores from 20 to 40:", upperBound(scores, 40) - lowerBound(scores, 20))
print("insert 60 at", lowerBound(scores, 60))
