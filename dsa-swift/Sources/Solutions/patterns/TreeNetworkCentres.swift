// Reference solution: Where to put the main router. A leaf is never a better spot than its neighbour, so
// peel the tree a layer of leaves at a time (Kahn's algorithm with degrees) until at most two buildings
// remain: the middle of the longest path. Each building is removed once: O(n) time and space.

public enum TreeNetworkCentres {
    public static func centres(buildings n: Int, cables: [[Int]]) -> [Int] {
        guard n > 2 else { return Array(0..<n) }
        var neighbours = Array(repeating: [Int](), count: n)
        var degree = Array(repeating: 0, count: n)
        for cable in cables {
            neighbours[cable[0]].append(cable[1])
            neighbours[cable[1]].append(cable[0])
            degree[cable[0]] += 1
            degree[cable[1]] += 1
        }
        var layer = (0..<n).filter { degree[$0] == 1 }
        var remaining = n
        while remaining > 2 {
            remaining -= layer.count
            var next: [Int] = []
            for leaf in layer {
                for neighbour in neighbours[leaf] {
                    degree[neighbour] -= 1
                    if degree[neighbour] == 1 {
                        next.append(neighbour)        // it just became a leaf of the smaller tree
                    }
                }
            }
            layer = next
        }
        return layer.sorted()
    }
}
