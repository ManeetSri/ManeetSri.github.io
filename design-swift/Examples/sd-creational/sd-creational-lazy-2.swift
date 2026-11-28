// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-lazy.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

actor RemoteConfig {
    private var cached: [String: Bool]?
    private var inFlight: Task<[String: Bool], any Error>?
    private let fetch: @Sendable () async throws -> [String: Bool]
    private(set) var fetches = 0

    init(fetch: @escaping @Sendable () async throws -> [String: Bool]) {
        self.fetch = fetch
    }

    func flags() async throws -> [String: Bool] {
        if let cached { return cached }
        // Someone is already loading: wait for their result instead of starting another load
        if let inFlight { return try await inFlight.value }

        fetches += 1
        let task = Task { try await fetch() }
        inFlight = task
        defer { inFlight = nil }

        // On failure nothing is cached, so the next call tries again
        let value = try await task.value
        cached = value
        return value
    }
}

let config = RemoteConfig(fetch: { ["newCheckout": true, "darkIcons": false] })

async let home = config.flags()
async let cart = config.flags()
async let settings = config.flags()
let all = try await [home, cart, settings]

print(all.map { $0["newCheckout"] ?? false })
print("fetches:", await config.fetches)
print("later call:", try await config.flags()["darkIcons"] ?? true, "fetches:", await config.fetches)
