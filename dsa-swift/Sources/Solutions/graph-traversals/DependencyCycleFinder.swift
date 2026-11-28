// Reference solution: Find a circular dependency. A three-colour DFS: white (0) is unvisited, grey
// (1) is on the current path, black (2) is finished. An edge to a grey module closes a loop. The DFS
// is iterative: each stack frame holds a module and the index of the next dependency to try, so a
// module turns black only after all its dependencies are done, exactly as in the recursive version.
// The stack holds the grey path in order, so the cycle is the slice of it from the grey module to
// the top. O(modules + dependencies) time and O(modules) space.

public enum DependencyCycleFinder {
    public static func cycle(_ modules: Int, dependencies: [[Int]]) -> [Int] {
        var needs = Array(repeating: [Int](), count: modules)
        for pair in dependencies {
            needs[pair[0]].append(pair[1])
        }

        var colour = Array(repeating: 0, count: modules)
        var stack: [(module: Int, next: Int)] = []
        for root in 0..<modules where colour[root] == 0 {
            colour[root] = 1
            stack.append((root, 0))
            while let top = stack.last {
                if top.next == needs[top.module].count {
                    colour[top.module] = 2               // every dependency is done
                    stack.removeLast()
                    continue
                }
                stack[stack.count - 1].next += 1
                let dependency = needs[top.module][top.next]
                if colour[dependency] == 0 {
                    colour[dependency] = 1
                    stack.append((dependency, 0))
                } else if colour[dependency] == 1 {
                    // Back to a module on the current path: the path from it to here is a loop
                    let start = stack.firstIndex { $0.module == dependency }!
                    return stack[start...].map(\.module)
                }
            }
        }
        return []
    }
}
