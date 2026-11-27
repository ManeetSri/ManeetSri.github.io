// Reference solution: Distinct tile arrangements. Permutations with a used array, over the tiles in
// sorted order. Equal tiles are always placed left to right: a copy is skipped while its equal
// neighbour on the left is still unused, because that neighbour has already been tried in this
// position and would grow the same subtree. Only distinct prefixes are ever built.
// O(n · A) time, where A is the number of distinct arrangements (at most n!), and O(n) extra space.

public enum DistinctTileArrangements {
    public static func arrangements(of tiles: String) -> [String] {
        let letters = tiles.sorted()
        var used = Array(repeating: false, count: letters.count)
        var current: [Character] = []
        var result: [String] = []

        func explore() {
            if current.count == letters.count {
                result.append(String(current))
                return
            }
            for i in letters.indices where !used[i] {
                if i > 0 && letters[i] == letters[i - 1] && !used[i - 1] { continue }
                used[i] = true                                      // choose
                current.append(letters[i])
                explore()                                           // explore
                current.removeLast()                                // unchoose
                used[i] = false
            }
        }

        explore()
        return result
    }
}
