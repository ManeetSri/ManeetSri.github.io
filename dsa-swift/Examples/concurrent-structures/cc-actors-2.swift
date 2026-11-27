// Generated from src/dsa/content/lessons/concurrent-structures/cc-actors.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Stands in for the network: counts requests and takes a while to answer
actor FakeServer {
    private(set) var requests = 0

    func download(_ name: String) async -> String {
        requests += 1
        for _ in 0..<10 {
            await Task.yield()          // let other tasks run, as a real download would
        }
        return "<\(name) image>"
    }
}

actor ImageCache {
    private var tasks: [String: Task<String, Never>] = [:]
    private let server: FakeServer

    init(server: FakeServer) {
        self.server = server
    }

    func image(named name: String) async -> String {
        if let task = tasks[name] {
            return await task.value                     // finished or still running: share it
        }
        let server = self.server
        let task = Task { await server.download(name) }
        tasks[name] = task                              // recorded before the first await
        return await task.value
    }
}

let server = FakeServer()
let cache = ImageCache(server: server)
let names = ["cat", "dog", "cat", "owl", "dog", "cat", "cat", "owl"]
let images = await withTaskGroup(of: String.self) { group in
    for name in names {
        group.addTask { await cache.image(named: name) }
    }
    var all: [String] = []
    for await image in group {
        all.append(image)
    }
    return all
}
print(images.count, Set(images).sorted())
print(await server.requests)
