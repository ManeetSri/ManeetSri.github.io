// Reference solution: Skyline outline. A sweep over 2n events: a building's height joins the active
// heights at its left edge and leaves at its right edge, and the outline's height is the tallest active
// height (0 if none). A start is encoded as (left, -height) and an end as (right, height), so sorting the
// pairs puts, at the same x, starts before ends, taller starts first and shorter ends first. A key point
// is recorded only when the height changes.
// The active heights live in a sorted array (with duplicates) found by binary search: O(n log n) for the
// sort plus O(n) per insert or remove for shifting, so O(n²) in the worst case. A heap with lazy deletion
// (M39) gives O(n log n). O(n) space.

public enum SkylineOutline {
    public static func keyPoints(_ buildings: [[Int]]) -> [[Int]] {
        var events: [(x: Int, key: Int)] = []
        events.reserveCapacity(buildings.count * 2)
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
            if points.last?[1] != height {
                points.append([event.x, height])
            }
        }
        return points
    }

    /// The heights of the buildings the sweep is passing, sorted so the tallest is last.
    private struct SortedHeights {
        private var items: [Int] = []

        /// The first index whose height is at least `height`. O(log n).
        private func lowerBound(_ height: Int) -> Int {
            var low = 0
            var high = items.count
            while low < high {
                let mid = low + (high - low) / 2
                if items[mid] < height {
                    low = mid + 1
                } else {
                    high = mid
                }
            }
            return low
        }

        /// Adds one copy of `height`. O(n) because of the shift.
        mutating func insert(_ height: Int) {
            items.insert(height, at: lowerBound(height))
        }

        /// Removes one copy of `height`, which must be present. O(n) because of the shift.
        mutating func remove(_ height: Int) {
            items.remove(at: lowerBound(height))
        }

        /// The tallest active height, or 0 for bare ground. O(1).
        var tallest: Int {
            items.last ?? 0
        }
    }
}
