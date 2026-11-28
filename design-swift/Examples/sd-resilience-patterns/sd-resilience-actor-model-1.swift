// Generated from src/dsa/design/content/lessons/sd-resilience-patterns/sd-resilience-actor-model.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// A stand-in for the server: every call waits until the demo opens it,
// so both exports are in flight at once, every time
actor Server {
    private var isOpen = false
    private var waiting: [CheckedContinuation<Void, Never>] = []

    func export() async {
        if isOpen { return }
        await withCheckedContinuation { waiting.append($0) }
    }

    func open() {
        isOpen = true
        waiting.forEach { $0.resume() }
        waiting.removeAll()
    }
}

actor ExportQuota {
    private(set) var remaining: Int
    private(set) var calls = 0
    private let server: Server

    init(remaining: Int, server: Server) {
        self.remaining = remaining
        self.server = server
    }

    // Bug: checks, suspends, then acts on a check that may no longer be true
    func exportCheckingFirst() async -> Bool {
        calls += 1
        guard remaining > 0 else { return false }
        await server.export()
        remaining -= 1
        return true
    }

    // Fix: claims the quota before the suspension point
    func exportReservingFirst() async -> Bool {
        calls += 1
        guard remaining > 0 else { return false }
        remaining -= 1
        await server.export()
        return true
    }
}

func twoExports(reserving: Bool) async -> String {
    let server = Server()
    let quota = ExportQuota(remaining: 1, server: server)
    async let first = reserving ? quota.exportReservingFirst() : quota.exportCheckingFirst()
    async let second = reserving ? quota.exportReservingFirst() : quota.exportCheckingFirst()
    while await quota.calls < 2 { await Task.yield() }
    await server.open()
    let succeeded = await [first, second].filter { $0 }.count
    return "exports: \(succeeded), remaining: \(await quota.remaining)"
}

print("Check, then await:  ", await twoExports(reserving: false))
print("Reserve, then await:", await twoExports(reserving: true))
