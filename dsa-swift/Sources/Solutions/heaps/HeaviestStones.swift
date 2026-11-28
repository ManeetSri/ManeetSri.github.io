// Reference solution: Smash the heaviest stones. A max-heap keeps the heaviest stone on top, so each
// turn is two pops and at most one insert, O(log n) each. There are at most n - 1 turns, because each
// turn removes at least one stone. O(n) to heapify, O(n log n) in total, O(n) extra space.

import DSAKit

public enum HeaviestStones {
    public static func lastStone(_ weights: [Int]) -> Int {
        var pile = Heap.maxHeap(weights)
        while pile.count > 1 {
            let heaviest = pile.pop()!
            let next = pile.pop()!
            if heaviest > next {
                pile.insert(heaviest - next)             // the survivor goes back on the pile
            }
        }
        return pile.peek() ?? 0
    }
}
