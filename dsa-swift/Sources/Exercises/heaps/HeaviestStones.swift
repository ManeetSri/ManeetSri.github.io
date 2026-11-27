// Problem: Smash the heaviest stones (M39 · Sift up and sift down)

import DSAKit

public enum HeaviestStones {
    /// Repeatedly smashes the two heaviest stones together: equal stones both crumble, otherwise the
    /// heavier one survives, lighter by the other's weight. Returns the weight of the last stone left,
    /// or 0 if none is left.
    public static func lastStone(_ weights: [Int]) -> Int {
        // Write your solution here, then run:
        // swift test --filter HeaviestStonesTests
        // DSAKit's Heap is imported, if you want it: Heap.maxHeap(weights) keeps the heaviest on top.
        return -1
    }
}
