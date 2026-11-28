// Reference solution: Folder sizes. A folder's total needs its subfolders' totals first, so the sums
// are a postorder computation: recurse, then add. The list of big folders must come out in preorder,
// though, so `walk` reserves the folder's slot in the list before recursing and fills in its total
// afterwards. Each function visits every folder once: O(n) time for n folders, plus the cost of
// building the path strings, and O(h) stack for h levels.

public enum FolderSizes {
    public final class Folder {
        public let name: String
        public let fileBytes: Int
        public var subfolders: [Folder]

        public init(_ name: String, fileBytes: Int = 0, subfolders: [Folder] = []) {
            self.name = name
            self.fileBytes = fileBytes
            self.subfolders = subfolders
        }
    }

    public static func totalBytes(_ folder: Folder) -> Int {
        folder.subfolders.reduce(folder.fileBytes) { $0 + totalBytes($1) }
    }

    public static func levels(_ folder: Folder) -> Int {
        1 + (folder.subfolders.map(levels).max() ?? 0)
    }

    public static func folders(atLeast threshold: Int, in root: Folder) -> [String] {
        var entries: [(path: String, total: Int)] = []

        func walk(_ folder: Folder, path: String) -> Int {
            let slot = entries.count
            entries.append((path, 0))                 // preorder position, total filled in below
            var total = folder.fileBytes
            for subfolder in folder.subfolders {
                total += walk(subfolder, path: path + "/" + subfolder.name)
            }
            entries[slot].total = total
            return total
        }

        _ = walk(root, path: root.name)
        return entries.filter { $0.total >= threshold }.map(\.path)
    }
}
