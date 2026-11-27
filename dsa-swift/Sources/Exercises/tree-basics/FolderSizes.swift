// Problem: Folder sizes (M34 · N-ary trees)

public enum FolderSizes {
    /// A folder: the bytes taken by the files directly inside it, and its subfolders, in order. A
    /// folder can have any number of subfolders, so this is an N-ary tree.
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

    /// The folder's own file bytes plus the totals of all its subfolders, all the way down.
    public static func totalBytes(_ folder: Folder) -> Int {
        // Write your solution here, then run:
        // swift test --filter FolderSizesTests
        return 0
    }

    /// The number of levels in the folder tree: 1 for a folder with no subfolders.
    public static func levels(_ folder: Folder) -> Int {
        return 0
    }

    /// The path of every folder whose total is at least `threshold`, in preorder: each folder before
    /// its subfolders, and subfolders in their order. A path is the folder names from the root down,
    /// joined with "/", such as "Home/Photos/2026".
    public static func folders(atLeast threshold: Int, in root: Folder) -> [String] {
        return []
    }
}
