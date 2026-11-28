// Reference solution: Count grid routes. The plain recursion (routes = routes with one row fewer +
// routes with one column fewer) is exponential, because the same smaller grids come up again and
// again. Memoising on (rows, columns) computes each of the rows × columns subproblems once:
// O(rows × columns) time and space, with recursion at most rows + columns deep.

public enum GridPathCount {
    private struct Size: Hashable {
        let rows: Int
        let columns: Int
    }

    public static func paths(rows: Int, columns: Int) -> Int {
        var cache: [Size: Int] = [:]

        func count(_ rows: Int, _ columns: Int) -> Int {
            if rows == 1 || columns == 1 {
                return 1                                    // one straight route
            }
            let key = Size(rows: rows, columns: columns)
            if let known = cache[key] {
                return known
            }
            let result = count(rows - 1, columns) + count(rows, columns - 1)
            cache[key] = result
            return result
        }

        return count(rows, columns)
    }
}
