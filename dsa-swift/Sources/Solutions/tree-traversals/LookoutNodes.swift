// Reference solution: Count the lookouts. Each node needs the largest value above it (passed down, as in
// preorder) and the largest value below it (returned up, as in postorder). An explicit stack of frames
// carries the downward value and a "children done" flag; a second stack collects each finished
// subtree's largest value for its parent. O(n) time, O(h) heap memory, safe on any depth.

import DSAKit

public enum LookoutNodes {
    public static func count(in root: TreeNode?) -> Int {
        guard let root else { return 0 }
        var lookouts = 0
        var frames: [(node: TreeNode, largestAbove: Int?, childrenDone: Bool)] = [(root, nil, false)]
        var subtreeMax: [Int] = []                     // answers coming back up
        while let (node, largestAbove, childrenDone) = frames.popLast() {
            if !childrenDone {
                frames.append((node, largestAbove, true))           // come back after the children
                let above = max(largestAbove ?? Int.min, node.value)
                if let left = node.left { frames.append((left, above, false)) }
                if let right = node.right { frames.append((right, above, false)) }
                continue
            }
            var largestBelow: Int? = nil
            let childCount = (node.left == nil ? 0 : 1) + (node.right == nil ? 0 : 1)
            for _ in 0..<childCount {                               // one answer per child
                let below = subtreeMax.removeLast()
                largestBelow = max(largestBelow ?? below, below)
            }
            let beatsAbove = largestAbove.map { node.value > $0 } ?? true
            let beatsBelow = largestBelow.map { node.value > $0 } ?? true
            if beatsAbove && beatsBelow { lookouts += 1 }
            subtreeMax.append(max(node.value, largestBelow ?? node.value))
        }
        return lookouts
    }
}
