// Reference solution: Build and unbuild a Fenwick array. Slot i's range is one of the blocks tiling the
// range of its parent, i + lowbit(i). So copy the items in, then visit the slots upwards and add each one
// into its parent: by the time a slot is visited, all its children are in. Undo it by subtracting, from
// the top slot down, so each slot still holds its full value when it leaves its parent. O(n) each way.

public enum FenwickLinearBuild {
    public static func build(_ items: [Int]) -> [Int] {
        let n = items.count
        var tree = [0] + items
        for i in stride(from: 1, through: n, by: 1) {
            let parent = i + (i & -i)
            if parent <= n {
                tree[parent] += tree[i]
            }
        }
        return tree
    }

    public static func items(from tree: [Int]) -> [Int] {
        let n = tree.count - 1
        var values = tree
        for i in stride(from: n, through: 1, by: -1) {
            let parent = i + (i & -i)
            if parent <= n {
                values[parent] -= values[i]           // values[i] is still its built value here
            }
        }
        return Array(values.dropFirst())
    }
}
