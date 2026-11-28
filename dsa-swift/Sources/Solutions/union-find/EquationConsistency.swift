// Reference solution: Can the equations all hold? Give each variable name an index. Equality is
// transitive, so first union the two sides of every "==" equation; then every "!=" equation is
// broken exactly when its two sides ended up in the same set. Checking the "!=" equations before
// all the "==" ones are in would miss equalities that arrive later. O(m α(m)) time for m equations,
// O(m) space.

import DSAKit

public enum EquationConsistency {
    public static func canSatisfy(_ equations: [[String]]) -> Bool {
        var indexOf: [String: Int] = [:]
        for equation in equations {
            for name in [equation[0], equation[2]] where indexOf[name] == nil {
                indexOf[name] = indexOf.count
            }
        }
        var sets = UnionFind(count: indexOf.count)
        for equation in equations where equation[1] == "==" {
            sets.union(indexOf[equation[0]]!, indexOf[equation[2]]!)
        }
        for equation in equations where equation[1] == "!=" {
            if sets.connected(indexOf[equation[0]]!, indexOf[equation[2]]!) {
                return false
            }
        }
        return true
    }
}
