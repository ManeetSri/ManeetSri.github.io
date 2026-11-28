// Reference solution: Smallest range touching every list. Keep one pointer per list, starting at the
// front. The pointed-at values always include one from every list, so [smallest, largest] of them is a
// candidate range. A min-heap gives the smallest; a variable tracks the largest. The only way to find
// a narrower range is to drop the smallest, so advance that list's pointer and repeat until some list
// runs out. Each of the N values enters the heap once: O(N log k) time, O(k) space.

import DSAKit

public enum SmallestSharedRange {
    public static func range(_ lists: [[Int]]) -> [Int] {
        // (value, which list, position in that list), smallest value on top
        var front = Heap(lists.indices.map { (value: lists[$0][0], list: $0, position: 0) },
                         areInIncreasingOrder: { $0.value < $1.value })
        var largest = lists.map { $0[0] }.max()!
        var best = [front.peek()!.value, largest]
        while let smallest = front.pop() {
            if largest - smallest.value < best[1] - best[0] {
                best = [smallest.value, largest]         // strictly narrower: earlier lows win ties
            }
            let next = smallest.position + 1
            guard next < lists[smallest.list].count else { break }    // that list has nothing left
            let value = lists[smallest.list][next]
            largest = max(largest, value)
            front.insert((value, smallest.list, next))
        }
        return best
    }
}
