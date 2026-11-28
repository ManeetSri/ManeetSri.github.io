// Generated from src/dsa/design/content/lessons/sd-resilience-patterns/sd-resilience-single-flight.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// A fake auth server: counts refreshes, and holds each one until the demo opens it
actor AuthServer {
    private(set) var refreshes = 0
    private var isOpen = false
    private var waiting: [CheckedContinuation<Void, Never>] = []

    func refresh() async -> String {
        refreshes += 1
        let issued = "token-\(refreshes)"
        if !isOpen {
            await withCheckedContinuation { waiting.append($0) }
        }
        return issued
    }

    func open() {
        isOpen = true
        waiting.forEach { $0.resume() }
        waiting.removeAll()
    }
}

actor TokenStore {
    private var token = "token-0"
    private var refreshing: Task<String, Never>?
    private(set) var requests = 0
    private let server: AuthServer

    init(server: AuthServer) {
        self.server = server
    }

    // Every request that got a 401 calls this with the token it used
    func freshToken(replacing stale: String) async -> String {
        requests += 1
        if token != stale {
            return token                          // already refreshed since that request was sent
        }
        if let refreshing {
            return await refreshing.value         // join the refresh in flight
        }
        let refresh = Task { await server.refresh() }
        refreshing = refresh                      // stored before the first await
        let fresh = await refresh.value
        token = fresh
        refreshing = nil
        return fresh
    }
}

let server = AuthServer()
let store = TokenStore(server: server)

// Three requests fail with 401 at about the same moment, all sent with token-0
async let feed = store.freshToken(replacing: "token-0")
async let profile = store.freshToken(replacing: "token-0")
async let inbox = store.freshToken(replacing: "token-0")
while await store.requests < 3 { await Task.yield() }
await server.open()
print("New tokens:", await [feed, profile, inbox])

// A fourth request, sent before the refresh, fails late: it gets the new token, not a second refresh
print("Late 401:", await store.freshToken(replacing: "token-0"))
print("Refreshes:", await server.refreshes)
