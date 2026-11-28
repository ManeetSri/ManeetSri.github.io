// Generated from src/dsa/content/lessons/efficient-sorts/sort-shell-timsort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Natural runs: stretches that are already in non-decreasing order
func runs(_ items: [Int]) -> [Int] {
    guard !items.isEmpty else { return [] }
    var lengths: [Int] = []
    var start = 0
    for i in 1...items.count where i == items.count || items[i] < items[i - 1] {
        lengths.append(i - start)            // the run ends before a step down
        start = i
    }
    return lengths
}

let yesterday = Array(stride(from: 10, through: 100, by: 10))
let appended = yesterday + [35, 90, 5]                       // a sorted list plus new arrivals
let twoFeeds = [3, 8, 15, 21, 40] + [1, 9, 12, 30, 33, 41]    // two sorted lists end to end
let scrambled = [42, 7, 19, 88, 3, 56, 23, 71, 12, 64]

print(runs(appended))
print(runs(twoFeeds))
print(runs(scrambled))
