// Reference solution: In-memory file system. A tree of directories, each holding two dictionaries:
// subdirectories by name and file contents by name. Every operation splits the path and walks it
// one name at a time, so it costs O(path length) on average, plus sorting the k names for `list`
// (O(k log k)) and the length of the text for `append` and `read`.

public enum InMemoryFileSystem {
    public final class FileSystem {
        private final class Directory {
            var directories: [String: Directory] = [:]
            var files: [String: String] = [:]
        }

        private let root = Directory()

        public init() {}

        public func makeDirectory(_ path: String) {
            _ = directory(at: names(in: path)[...], creating: true)
        }

        public func list(_ path: String) -> [String] {
            let parts = names(in: path)
            if let name = parts.last, let parent = directory(at: parts.dropLast(), creating: false),
               parent.files[name] != nil {
                return [name]                                    // a file lists itself
            }
            guard let folder = directory(at: parts[...], creating: false) else { return [] }
            return (Array(folder.directories.keys) + Array(folder.files.keys)).sorted()
        }

        public func append(_ content: String, toFile path: String) {
            let parts = names(in: path)
            guard let name = parts.last else { return }          // "/" is a directory, not a file
            let parent = directory(at: parts.dropLast(), creating: true)!
            parent.files[name, default: ""] += content           // appends in place
        }

        public func read(_ path: String) -> String? {
            let parts = names(in: path)
            guard let name = parts.last, let parent = directory(at: parts.dropLast(), creating: false) else {
                return nil
            }
            return parent.files[name]
        }

        @discardableResult
        public func remove(_ path: String) -> Bool {
            let parts = names(in: path)
            guard let name = parts.last, let parent = directory(at: parts.dropLast(), creating: false) else {
                return false                                     // the root can't be removed
            }
            if parent.files.removeValue(forKey: name) != nil {
                return true
            }
            return parent.directories.removeValue(forKey: name) != nil   // takes everything inside
        }

        /// "/a/b/c" gives ["a", "b", "c"], and "/" gives [].
        private func names(in path: String) -> [String] {
            path.split(separator: "/").map(String.init)
        }

        /// The directory reached by following `names` from the root, making missing ones if asked.
        private func directory(at names: ArraySlice<String>, creating: Bool) -> Directory? {
            var current = root
            for name in names {
                if let next = current.directories[name] {
                    current = next
                } else if creating {
                    let made = Directory()
                    current.directories[name] = made
                    current = made
                } else {
                    return nil
                }
            }
            return current
        }
    }
}
