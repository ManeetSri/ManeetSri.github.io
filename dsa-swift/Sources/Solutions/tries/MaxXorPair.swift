// Reference solution: Largest XOR of a pair. A binary trie holds each number as 31 bits, from bit 30
// down to bit 0. To find the best partner for x, walk down from the top bit, taking the child with the
// opposite bit whenever it exists: a 1 in a higher bit is worth more than all lower bits together, so
// this greedy choice is always right. Insert each number, then query it against everything inserted so
// far (itself included, so the answer is at least 0). The trie lives in a flat array: node k's
// children are at 2k and 2k + 1, and 0 means "no child" because the root is never anyone's child.
// O(31 × n) time and space.

public enum MaxXorPair {
    public static func largestXor(in numbers: [Int]) -> Int {
        var children = [0, 0]                    // the root's two child slots
        var best = 0
        for x in numbers {
            var node = 0
            for bit in stride(from: 30, through: 0, by: -1) {
                let slot = 2 * node + ((x >> bit) & 1)
                if children[slot] == 0 {
                    children[slot] = children.count / 2
                    children.append(0)
                    children.append(0)
                }
                node = children[slot]
            }

            node = 0
            var value = 0
            for bit in stride(from: 30, through: 0, by: -1) {
                let opposite = 1 - ((x >> bit) & 1)
                if children[2 * node + opposite] != 0 {
                    value |= 1 << bit
                    node = children[2 * node + opposite]
                } else {
                    node = children[2 * node + 1 - opposite]
                }
            }
            best = max(best, value)
        }
        return best
    }
}
