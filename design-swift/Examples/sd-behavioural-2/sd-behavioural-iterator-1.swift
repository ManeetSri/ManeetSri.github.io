// Generated from src/dsa/design/content/lessons/sd-behavioural-2/sd-behavioural-iterator.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Folder {
    let name: String
    var files: [String] = []
    var subfolders: [Folder] = []
}

// Every file path in the tree, depth first. Callers never see how folders store their contents.
extension Folder: Sequence {
    struct Iterator: IteratorProtocol {
        var pendingFolders: [(path: String, folder: Folder)]
        var pendingFiles: [String] = []

        mutating func next() -> String? {
            while pendingFiles.isEmpty {
                guard let (path, folder) = pendingFolders.popLast() else { return nil }
                pendingFiles = folder.files.reversed().map { "\(path)/\($0)" }
                pendingFolders += folder.subfolders.reversed().map { ("\(path)/\($0.name)", $0) }
            }
            return pendingFiles.popLast()
        }
    }

    func makeIterator() -> Iterator {
        Iterator(pendingFolders: [(name, self)])
    }
}

let photos = Folder(name: "Photos", files: ["cover.heic"], subfolders: [
    Folder(name: "2024", files: ["beach.heic", "notes.txt"], subfolders: [
        Folder(name: "Paris", files: ["eiffel.heic"]),
    ]),
    Folder(name: "2025", files: ["snow.heic"]),
])

for path in photos {
    print(path)
}

// Sequence gives every algorithm for free, built on next()
print(photos.filter { $0.hasSuffix(".heic") }.count, "photos")
print(photos.first { $0.contains("Paris") } ?? "none")
print(photos.contains("Photos/2025/snow.heic"))
