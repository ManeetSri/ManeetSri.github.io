// Generated from src/dsa/content/lessons/swift-closures/swift-escaping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var pendingWork: [() -> Void] = []

func loadScore(for player: String, completion: @escaping (Int) -> Void) {
    pendingWork.append {
        let score = player.count * 10   // pretend this came from a server
        completion(score)
    }
    print("Asked for \(player)'s score")
}

loadScore(for: "Ada") { score in
    print("Ada scored \(score)")
}
loadScore(for: "Maneet") { score in
    print("Maneet scored \(score)")
}

print("Doing other things...")

// Later, the work finishes
for work in pendingWork {
    work()
}
