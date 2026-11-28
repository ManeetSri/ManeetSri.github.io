import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct InMemoryFileSystemTests {
    typealias FileSystem = InMemoryFileSystem.FileSystem

    /// A tiny deterministic generator, so the random tests do the same thing every run.
    private struct Steps {
        private var state: UInt64
        init(seed: UInt64) { state = seed }
        mutating func next(below limit: Int) -> Int {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            return Int((state >> 33) % UInt64(limit))
        }
    }

    /// The obvious slow version: a flat dictionary of file paths and a set of directory paths.
    private struct Model {
        var files: [String: String] = [:]
        var directories: Set<String> = ["/"]

        static func parent(of path: String) -> String {
            let names = path.split(separator: "/")
            return "/" + names.dropLast().joined(separator: "/")
        }

        static func name(of path: String) -> String {
            String(path.split(separator: "/").last ?? "")
        }

        mutating func makeDirectory(_ path: String) {
            var current = ""
            for name in path.split(separator: "/") {
                current += "/" + name
                directories.insert(current)
            }
        }

        mutating func append(_ content: String, toFile path: String) {
            makeDirectory(Model.parent(of: path))
            files[path, default: ""] += content
        }

        func list(_ path: String) -> [String] {
            if files[path] != nil { return [Model.name(of: path)] }
            guard directories.contains(path) else { return [] }
            let children = directories.filter { $0 != "/" && Model.parent(of: $0) == path }
                .union(files.keys.filter { Model.parent(of: $0) == path })
            return children.map { Model.name(of: $0) }.sorted()
        }

        mutating func remove(_ path: String) -> Bool {
            if path == "/" { return false }
            if files.removeValue(forKey: path) != nil { return true }
            guard directories.contains(path) else { return false }
            directories = directories.filter { $0 != path && !$0.hasPrefix(path + "/") }
            files = files.filter { !$0.key.hasPrefix(path + "/") }
            return true
        }
    }

    @Test("Directories, files and listings work together")
    func example() {
        let disk = FileSystem()
        #expect(disk.list("/") == [])
        disk.makeDirectory("/notes/swift")
        disk.append("Heaps keep the smallest on top.", toFile: "/notes/swift/heaps.txt")
        disk.append(" Sift up after insert.", toFile: "/notes/swift/heaps.txt")
        disk.append("milk, eggs", toFile: "/todo.txt")
        #expect(disk.list("/") == ["notes", "todo.txt"])
        #expect(disk.list("/notes/swift") == ["heaps.txt"])
        #expect(disk.list("/notes/swift/heaps.txt") == ["heaps.txt"])
        #expect(disk.read("/notes/swift/heaps.txt") == "Heaps keep the smallest on top. Sift up after insert.")
        #expect(disk.read("/notes/swift") == nil)
        #expect(disk.read("/missing.txt") == nil)
        #expect(disk.list("/nowhere") == [])
    }

    @Test("makeDirectory creates every missing directory on the way")
    func makesParents() {
        let disk = FileSystem()
        disk.makeDirectory("/a/b/c")
        #expect(disk.list("/") == ["a"])
        #expect(disk.list("/a") == ["b"])
        #expect(disk.list("/a/b") == ["c"])
        #expect(disk.list("/a/b/c") == [])
        disk.makeDirectory("/a/b/c")                       // already there: nothing changes
        disk.makeDirectory("/a/x")
        #expect(disk.list("/a") == ["b", "x"])
    }

    @Test("append creates the file and its directories")
    func appendCreates() {
        let disk = FileSystem()
        disk.append("one", toFile: "/deep/down/here/file")
        #expect(disk.list("/deep/down") == ["here"])
        #expect(disk.read("/deep/down/here/file") == "one")
        disk.append("", toFile: "/empty")
        #expect(disk.read("/empty") == "")
        #expect(disk.list("/") == ["deep", "empty"])
    }

    @Test("Listings mix directories and files in sorted order")
    func sortedListing() {
        let disk = FileSystem()
        for name in ["beta.txt", "Zeta", "alpha", "2", "10"] {
            disk.append("x", toFile: "/mix/" + name)
        }
        disk.makeDirectory("/mix/gamma")
        disk.makeDirectory("/mix/Alpha")
        #expect(disk.list("/mix") == ["10", "2", "Alpha", "Zeta", "alpha", "beta.txt", "gamma"])
    }

    @Test("remove takes out a file, or a directory with everything inside")
    func removing() {
        let disk = FileSystem()
        disk.append("a", toFile: "/projects/app/main.swift")
        disk.append("b", toFile: "/projects/app/tests/test.swift")
        disk.append("c", toFile: "/projects/readme")
        #expect(disk.remove("/projects/app/main.swift"))
        #expect(disk.list("/projects/app") == ["tests"])
        #expect(disk.remove("/projects/app"))
        #expect(disk.read("/projects/app/tests/test.swift") == nil)
        #expect(disk.list("/projects") == ["readme"])
        #expect(!disk.remove("/projects/app"))
        #expect(!disk.remove("/nothing/here"))
        #expect(!disk.remove("/"))
        #expect(disk.read("/projects/readme") == "c")
        disk.append("d", toFile: "/projects/app/main.swift")
        #expect(disk.read("/projects/app/main.swift") == "d", "a removed path can be used again")
    }

    @Test("Thousands of mixed calls match a simple model", arguments: [1, 2, 3])
    func matchesModel(seed: Int) {
        var steps = Steps(seed: UInt64(seed) &* 3_571)
        let directoryNames = ["docs", "src", "img"]
        let fileNames = ["a.txt", "b.md", "notes"]        // never a directory name, so paths never clash
        let disk = FileSystem()
        var model = Model()

        func randomDirectory() -> String {
            var path = ""
            for _ in 0..<steps.next(below: 4) {
                path += "/" + directoryNames[steps.next(below: directoryNames.count)]
            }
            return path.isEmpty ? "/" : path
        }
        func randomFile() -> String {
            let directory = randomDirectory()
            return (directory == "/" ? "" : directory) + "/" + fileNames[steps.next(below: fileNames.count)]
        }

        for step in 0..<3_000 {
            switch steps.next(below: 7) {
            case 0:
                let path = randomDirectory()
                disk.makeDirectory(path)
                model.makeDirectory(path)
            case 1, 2:
                let path = randomFile()
                let content = String(repeating: "x", count: steps.next(below: 3)) + "\(step)"
                disk.append(content, toFile: path)
                model.append(content, toFile: path)
            case 3:
                let path = randomFile()
                if disk.read(path) != model.files[path] {
                    Issue.record("read(\"\(path)\") is wrong at step \(step)")
                    return
                }
            case 4:
                let path = steps.next(below: 2) == 0 ? randomDirectory() : randomFile()
                if steps.next(below: 3) == 0 && disk.remove(path) != model.remove(path) {
                    Issue.record("remove(\"\(path)\") returned the wrong answer at step \(step)")
                    return
                }
            default:
                let path = steps.next(below: 3) == 0 ? randomFile() : randomDirectory()
                if disk.list(path) != model.list(path) {
                    Issue.record("list(\"\(path)\") is wrong at step \(step)")
                    return
                }
            }
        }
    }

    @Test("20,000 files in one directory, 200 levels deep, and 100,000 appends", .timeLimit(.minutes(1)))
    func large() {
        let disk = FileSystem()
        var names: [String] = []
        for number in 0..<20_000 {
            let name = "file\((number * 7_919) % 20_000).txt"
            names.append(name)
            disk.append("\(number)", toFile: "/big/" + name)
        }
        #expect(disk.list("/big") == names.sorted())

        let deep = (0..<200).map { "level\($0)" }.joined(separator: "/")
        disk.makeDirectory("/" + deep)
        disk.append("bottom", toFile: "/" + deep + "/leaf")
        #expect(disk.read("/" + deep + "/leaf") == "bottom")
        #expect(disk.list("/" + deep) == ["leaf"])

        for _ in 0..<100_000 {
            disk.append("ab", toFile: "/log.txt")
        }
        #expect(disk.read("/log.txt")?.count == 200_000)
        #expect(disk.list("/") == ["big", "level0", "log.txt"])
    }
}
