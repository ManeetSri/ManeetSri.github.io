// Problem: List every folder's path (M68 · Avoiding accidental copies)

public enum FolderPathListing {
    /// Works in UTF-8 bytes. Because every parent comes before its children, one pass computes each
    /// folder's path length and the exact size of the output, so the output buffer is reserved once. A
    /// depth-first walk with an explicit stack then keeps the current path in one byte buffer: entering a
    /// folder appends "/name", leaving it truncates back. Each line is one copy of that buffer.
    ///
    /// O(n + output size) time, and the output plus O(n) extra space.
    public static func listing(names: [String], parents: [Int]) -> String {
        let n = names.count
        guard n > 0 else { return "" }
        let nameBytes = names.map { Array($0.utf8) }

        // Children in index order, stored as one flat array (start offsets plus targets)
        var childCount = Array(repeating: 0, count: n + 1)
        for folder in 1..<n {
            childCount[parents[folder] + 1] += 1
        }
        for index in 1...n {
            childCount[index] += childCount[index - 1]
        }
        var start = childCount                       // start[f]..<start[f + 1] are f's children
        var children = Array(repeating: 0, count: max(n - 1, 0))
        for folder in 1..<n {
            children[start[parents[folder]]] = folder
            start[parents[folder]] += 1
        }
        start = childCount

        // Path lengths, and the exact output size: every path plus its newline
        var pathLength = Array(repeating: 0, count: n)
        pathLength[0] = nameBytes[0].count
        var total = pathLength[0] + 1
        for folder in 1..<n {
            pathLength[folder] = pathLength[parents[folder]] + 1 + nameBytes[folder].count
            total += pathLength[folder] + 1
        }

        var output: [UInt8] = []
        output.reserveCapacity(total)
        var path: [UInt8] = []
        path.reserveCapacity(pathLength.max() ?? 0)

        // Explicit stack, so a very deep chain can't overflow the call stack. Children are pushed in
        // reverse so the smallest index comes off first.
        var stack = [0]
        while let folder = stack.popLast() {
            let parentLength = folder == 0 ? 0 : pathLength[parents[folder]]
            path.removeLast(path.count - parentLength)      // back up to the parent's path
            if folder != 0 {
                path.append(UInt8(ascii: "/"))
            }
            path.append(contentsOf: nameBytes[folder])
            output.append(contentsOf: path)
            output.append(UInt8(ascii: "\n"))
            var child = start[folder + 1]
            while child > start[folder] {
                child -= 1
                stack.append(children[child])
            }
        }
        return String(decoding: output, as: UTF8.self)
    }
}
