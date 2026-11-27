// Generated from src/dsa/content/lessons/recursion/rec-explicit-stack.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Folder {
    let name: String
    let subfolders: [Folder]
}

enum Step {
    case open(Folder, depth: Int)
    case close(String, depth: Int)
}

func printTags(_ root: Folder) {
    var stack: [Step] = [.open(root, depth: 0)]
    while let step = stack.popLast() {
        switch step {
        case let .open(folder, depth):
            let indent = String(repeating: "  ", count: depth)
            if folder.subfolders.isEmpty {
                print("\(indent)<\(folder.name)/>")
            } else {
                print("\(indent)<\(folder.name)>")
                stack.append(.close(folder.name, depth: depth))   // comes off after the children
                for subfolder in folder.subfolders.reversed() {
                    stack.append(.open(subfolder, depth: depth + 1))
                }
            }
        case let .close(name, depth):
            print(String(repeating: "  ", count: depth) + "</\(name)>")
        }
    }
}

let projects = Folder(name: "Projects", subfolders: [
    Folder(name: "App", subfolders: [
        Folder(name: "Sources", subfolders: []),
        Folder(name: "Tests", subfolders: []),
    ]),
    Folder(name: "Notes", subfolders: []),
])
printTags(projects)
