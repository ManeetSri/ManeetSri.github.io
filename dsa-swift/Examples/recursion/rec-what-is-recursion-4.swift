// Generated from src/dsa/content/lessons/recursion/rec-what-is-recursion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Folder {
    let name: String
    let files: Int
    let subfolders: [Folder]
}

func totalFiles(in folder: Folder) -> Int {
    var total = folder.files
    for subfolder in folder.subfolders {
        total += totalFiles(in: subfolder)
    }
    return total
}

let photos = Folder(name: "Photos", files: 120, subfolders: [
    Folder(name: "2025", files: 40, subfolders: []),
    Folder(name: "2026", files: 15, subfolders: [
        Folder(name: "Holiday", files: 60, subfolders: []),
    ]),
])
print(totalFiles(in: photos))
