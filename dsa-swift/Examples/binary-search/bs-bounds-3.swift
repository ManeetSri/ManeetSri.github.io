// Generated from src/dsa/content/lessons/binary-search/bs-bounds.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstIndex(in items: [Int], where condition: (Int) -> Bool) -> Int {
    var low = 0
    var high = items.count
    while low < high {
        let mid = low + (high - low) / 2
        if condition(items[mid]) {
            high = mid
        } else {
            low = mid + 1
        }
    }
    return low
}

func lowerBound(_ items: [Int], _ x: Int) -> Int { firstIndex(in: items) { $0 >= x } }
func upperBound(_ items: [Int], _ x: Int) -> Int { firstIndex(in: items) { $0 > x } }

var starts = [540, 545, 600, 600, 615, 660, 700]     // 9:00, 9:05, 10:00, …

print("events at 10:00:", upperBound(starts, 600) - lowerBound(starts, 600))
print("events from 10:00 to 11:00:", upperBound(starts, 660) - lowerBound(starts, 600))
print("events at 9:30:", upperBound(starts, 570) - lowerBound(starts, 570))

let next = lowerBound(starts, 610)
print("first event at or after 10:10 starts at", starts[next])

starts.insert(605, at: lowerBound(starts, 605))      // stays sorted
print(starts)
