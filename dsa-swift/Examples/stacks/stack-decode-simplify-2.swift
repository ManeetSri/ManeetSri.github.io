// Generated from src/dsa/content/lessons/stacks/stack-decode-simplify.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func simplify(_ path: String) -> String {
    var folders: [Substring] = []
    for part in path.split(separator: "/") {     // repeated slashes give no empty parts
        switch part {
        case ".":
            continue
        case "..":
            _ = folders.popLast()                // at the root, there's nothing to pop
        default:
            folders.append(part)
        }
    }
    return "/" + folders.joined(separator: "/")
}

for path in ["/home//user/./docs/../photos/", "/../", "/a/./b/../../c/", "/.../x", "/"] {
    print("\(path) -> \(simplify(path))")
}
