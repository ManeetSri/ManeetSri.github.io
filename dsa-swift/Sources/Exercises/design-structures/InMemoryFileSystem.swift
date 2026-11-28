// Problem: In-memory file system (M72 · In-memory file system)

public enum InMemoryFileSystem {
    /// A file system that lives in memory. Paths are absolute, like "/notes/swift/heaps.txt".
    public final class FileSystem {
        // Write your solution here, then run:
        // swift test --filter InMemoryFileSystemTests
        // Add whatever private storage you need.

        /// Creates a file system holding only the empty root directory, "/".
        public init() {
        }

        /// Creates the directory at `path`, along with any missing directories above it.
        public func makeDirectory(_ path: String) {
        }

        /// For a directory: the names of everything directly inside it, sorted. For a file: just its
        /// own name. For a path that doesn't exist: an empty array.
        public func list(_ path: String) -> [String] {
            return []
        }

        /// Adds `content` to the end of the file at `path`, creating the file and any missing
        /// directories above it first.
        public func append(_ content: String, toFile path: String) {
        }

        /// The contents of the file at `path`, or nil if there's no file there.
        public func read(_ path: String) -> String? {
            return nil
        }

        /// Removes the file or directory (with everything inside it) at `path`. Returns false if
        /// nothing is there. The root can't be removed.
        @discardableResult
        public func remove(_ path: String) -> Bool {
            return false
        }
    }
}
