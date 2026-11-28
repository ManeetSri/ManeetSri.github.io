// Reference solution: Depths without deep recursion. Climb with a loop into a heap-allocated path until
// reaching a known depth or passing the root, then fill the path in backwards. Each person is climbed
// and filled once: O(n) time and space, constant stack.

public enum ParentChainDepths {
    public static func depths(_ parents: [Int]) -> [Int] {
        var depth = Array(repeating: -1, count: parents.count)     // −1: not known yet
        for start in 0..<parents.count where depth[start] == -1 {
            var path: [Int] = []
            var person = start
            while person != -1 && depth[person] == -1 {
                path.append(person)
                person = parents[person]
            }
            var known = person == -1 ? -1 : depth[person]           // −1 + 1 = 0 for the root
            for waiting in path.reversed() {
                known += 1
                depth[waiting] = known
            }
        }
        return depth
    }
}
