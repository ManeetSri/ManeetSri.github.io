// Generated from src/dsa/design/content/lessons/sd-resilience-patterns/sd-resilience-timeouts-cancellation.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

actor Log {
    private var lines: [String] = []
    func add(_ line: String) { lines.append(line) }
    var sorted: [String] { lines.sorted() }
}

// Stands in for a request that would take a minute
func load(_ name: String, log: Log) async {
    do {
        try await Task.sleep(for: .seconds(60))
        await log.add("\(name): finished")
    } catch {
        await log.add("\(name): cancelled")
    }
}

let log = Log()
let screen = Task {
    async let profile: Void = load("profile", log: log)
    async let feed: Void = withTaskGroup(of: Void.self) { group in
        for image in 1...3 {
            group.addTask { await load("image \(image)", log: log) }
        }
    }
    let analytics = Task { await load("analytics", log: log) } // unstructured: not a child
    _ = await (profile, feed)
    return analytics
}

screen.cancel()                     // the user leaves the screen
let analytics = await screen.value  // returns once every child has stopped
for line in await log.sorted {
    print(line)
}
print("Unstructured analytics task cancelled too:", analytics.isCancelled)
analytics.cancel()
