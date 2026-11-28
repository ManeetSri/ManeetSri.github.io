// Generated from src/dsa/content/lessons/binary-search/bs-rotated.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func minimumWithRepeats(_ items: [Int]) -> (value: Int, passes: Int) {
    var low = 0
    var high = items.count - 1
    var passes = 0
    while low < high {
        passes += 1
        let mid = low + (high - low) / 2
        if items[mid] > items[high] {
            low = mid + 1
        } else if items[mid] < items[high] {
            high = mid
        } else {
            high -= 1              // can't tell which side: drop one copy
        }
    }
    return (items[low], passes)
}

let distinct = Array(300..<1_000) + Array(0..<300)       // rotated, no repeats
print("distinct:", minimumWithRepeats(distinct))

for zeroAt in [999, 600, 0] {
    var ones = Array(repeating: 1, count: 1_000)
    ones[zeroAt] = 0
    print("one 0 at \(zeroAt):", minimumWithRepeats(ones))
}
