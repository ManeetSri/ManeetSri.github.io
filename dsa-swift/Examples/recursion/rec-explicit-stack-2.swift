// Generated from src/dsa/content/lessons/recursion/rec-explicit-stack.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Folder {
    let name: String
    let subfolders: [Folder]
}

let projects = Folder(name: "Projects", subfolders: [
    Folder(name: "App", subfolders: [
        Folder(name: "Sources", subfolders: []),
        Folder(name: "Tests", subfolders: []),
    ]),
    Folder(name: "Notes", subfolders: []),
])

func printTree(_ folder: Folder, depth: Int = 0) {
    print(String(repeating: "  ", count: depth) + folder.name)
    for subfolder in folder.subfolders {
        printTree(subfolder, depth: depth + 1)
    }
}

func printTreeWithStack(_ root: Folder) {
    var stack: [(folder: Folder, depth: Int)] = [(root, 0)]
    while let (folder, depth) = stack.popLast() {
        print(String(repeating: "  ", count: depth) + folder.name)
        for subfolder in folder.subfolders.reversed() {
            stack.append((subfolder, depth + 1))
        }
    }
}

printTree(projects)
print("---")
printTreeWithStack(projects)
