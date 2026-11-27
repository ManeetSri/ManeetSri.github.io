// Generated from src/dsa/content/lessons/tree-basics/tree-real-world.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct FileItem {
    let name: String
    var bytes = 0                 // a file's own size; folders hold nothing directly here
    var children: [FileItem] = []
    var isFolder: Bool { !children.isEmpty }
}

// Postorder: measure every child, then report the folder's total
func du(_ item: FileItem, path: String) -> Int {
    var total = item.bytes
    for child in item.children {
        total += du(child, path: path + "/" + child.name)
    }
    if item.isFolder {
        print("\(total)\t\(path)")
    }
    return total
}

let project = FileItem(name: "Project", children: [
    FileItem(name: "README.md", bytes: 2_000),
    FileItem(name: "Sources", children: [
        FileItem(name: "App.swift", bytes: 12_000),
        FileItem(name: "Model.swift", bytes: 8_000),
    ]),
    FileItem(name: "Tests", children: [FileItem(name: "AppTests.swift", bytes: 5_000)]),
    FileItem(name: "Assets", children: [FileItem(name: "icon.png", bytes: 150_000)]),
])
_ = du(project, path: project.name)
