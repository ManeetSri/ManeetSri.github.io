// Generated from src/dsa/content/lessons/design-structures/ds-file-system.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class FileSystem {
    private final class Node {
        var children: [String: Node] = [:]          // what a directory contains, by name
        var content: String?                        // nil for a directory, the text for a file

        init(content: String? = nil) {
            self.content = content
        }
    }

    private let root = Node()

    /// Follows `names` from the root, making missing directories if asked.
    private func walk(_ names: [Substring], creating: Bool) -> Node? {
        var node = root
        for name in names {
            if let next = node.children[String(name)] {
                node = next
            } else if creating {
                let made = Node()
                node.children[String(name)] = made
                node = made
            } else {
                return nil
            }
        }
        return node
    }

    func mkdir(_ path: String) {
        _ = walk(path.split(separator: "/"), creating: true)
    }

    func addContent(_ text: String, to path: String) {
        let names = path.split(separator: "/")
        let folder = walk(Array(names.dropLast()), creating: true)!
        let name = String(names.last!)
        let file = folder.children[name] ?? Node(content: "")   // reuse the file if it exists
        folder.children[name] = file
        file.content! += text
    }

    func readContent(_ path: String) -> String? {
        walk(path.split(separator: "/"), creating: false)?.content
    }

    func ls(_ path: String) -> [String] {
        let names = path.split(separator: "/")
        guard let node = walk(names, creating: false) else { return [] }
        if node.content != nil {
            return [String(names.last!)]                         // a file lists only itself
        }
        return node.children.keys.sorted()                       // O(k log k) for k entries
    }
}

let disk = FileSystem()
disk.mkdir("/notes/swift")
disk.addContent("Heaps keep the smallest on top.", to: "/notes/swift/heaps.txt")
disk.addContent(" Tries share prefixes.", to: "/notes/swift/heaps.txt")
disk.addContent("milk, eggs", to: "/todo.txt")
disk.mkdir("/photos")
print(disk.ls("/"))
print(disk.ls("/notes/swift"))
print(disk.ls("/notes/swift/heaps.txt"))
print(disk.readContent("/notes/swift/heaps.txt") ?? "no such file")
print(disk.readContent("/notes") ?? "no such file")
print(disk.ls("/missing"))
