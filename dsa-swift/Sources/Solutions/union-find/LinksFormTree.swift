// Reference solution: Do the links form a tree? A tree on n nodes has exactly n - 1 edges and no
// cycle. Check the count first, then union every link: a union that fails means the link joins two
// nodes that were already connected, which closes a cycle. With n - 1 links and no cycle, the
// graph is connected too. O(n α(n)) time, O(n) space.

import DSAKit

public enum LinksFormTree {
    public static func check(_ n: Int, _ links: [[Int]]) -> Bool {
        guard links.count == n - 1 else { return false }
        var nodes = UnionFind(count: n)
        for link in links where !nodes.union(link[0], link[1]) {
            return false
        }
        return true
    }
}
