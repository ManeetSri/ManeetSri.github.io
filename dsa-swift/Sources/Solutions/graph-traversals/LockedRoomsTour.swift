// Reference solution: Unlock every room. The rooms are vertices and each key is a directed edge, so
// the question is whether everything is reachable from room 0. An iterative DFS with an explicit
// stack opens each room once, marking it when its key is first found, and counts the rooms opened.
// O(rooms + keys) time and O(rooms) space, and no recursion, so a chain of 100,000 rooms is fine.

public enum LockedRoomsTour {
    public static func canOpenAll(_ keys: [[Int]]) -> Bool {
        var opened = Array(repeating: false, count: keys.count)
        opened[0] = true
        var openedCount = 1
        var stack = [0]
        while let room = stack.popLast() {
            for key in keys[room] where !opened[key] {
                opened[key] = true                       // mark when found, so it's pushed once
                openedCount += 1
                stack.append(key)
            }
        }
        return openedCount == keys.count
    }
}
