// Reference solution: Count the friend groups. Every person starts in a group of their own, and each
// friendship unions two groups. A union that joins two different groups lowers the count by one; a
// friendship inside a group changes nothing. O(n + f α(n)) time for f friendships, O(n) space.

import DSAKit

public enum FriendGroupCount {
    public static func count(_ n: Int, _ friendships: [[Int]]) -> Int {
        var groups = UnionFind(count: n)
        for pair in friendships {
            groups.union(pair[0], pair[1])
        }
        return groups.componentCount
    }
}
