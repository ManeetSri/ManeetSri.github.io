// Generated from src/dsa/content/lessons/intervals/iv-skyline.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Active heights, sorted so the tallest is last. Duplicates are kept.
struct SortedHeights {
    private var items: [Int] = []

    // The first index whose value is at least `height`
    private func lowerBound(_ height: Int) -> Int {
        var low = 0
        var high = items.count
        while low < high {
            let mid = low + (high - low) / 2
            if items[mid] < height { low = mid + 1 } else { high = mid }
        }
        return low
    }

    mutating func insert(_ height: Int) {
        items.insert(height, at: lowerBound(height))     // O(log n) to find, O(n) to shift
    }

    mutating func remove(_ height: Int) {
        items.remove(at: lowerBound(height))             // one copy, not all of them
    }

    var tallest: Int { items.last ?? 0 }                  // 0 is bare ground
}

func skyline(_ buildings: [[Int]]) -> [[Int]] {
    // A start is (left, -height) and an end is (right, height). Sorting the pairs puts, at the same x,
    // starts before ends, taller starts first and shorter ends first.
    var events: [(x: Int, key: Int)] = []
    for building in buildings {
        events.append((building[0], -building[2]))
        events.append((building[1], building[2]))
    }
    events.sort { ($0.x, $0.key) < ($1.x, $1.key) }

    var active = SortedHeights()
    var points: [[Int]] = []
    for event in events {
        if event.key < 0 {
            active.insert(-event.key)
        } else {
            active.remove(event.key)
        }
        let height = active.tallest
        if points.last?[1] != height {                   // only a change of height is a key point
            points.append([event.x, height])
        }
    }
    return points
}

print(skyline([[1, 5, 3], [2, 4, 6], [3, 8, 4], [10, 12, 2]]))
print(skyline([[0, 3, 5], [3, 6, 5]]))
print(skyline([[1, 4, 2], [1, 4, 7], [1, 4, 5]]))
