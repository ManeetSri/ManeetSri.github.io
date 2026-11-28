// Generated from src/dsa/design/content/lessons/sd-modelling/sd-modelling-interfaces.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

actor ImageLoader {
    private var cache: [URL: Data] = [:]
    private var inFlight: [URL: Task<Data, any Error>] = [:]
    private let fetch: @Sendable (URL) async throws -> Data

    init(fetch: @escaping @Sendable (URL) async throws -> Data) {
        self.fetch = fetch
    }

    /// The image data at `url`: from memory if we have it, joining a download already
    /// in flight if there is one, and downloading it otherwise.
    func data(for url: URL) async throws -> Data {
        if let cached = cache[url] { return cached }
        if let running = inFlight[url] { return try await running.value }

        let task = Task { try await fetch(url) }
        inFlight[url] = task
        defer { inFlight[url] = nil }
        let data = try await task.value
        cache[url] = data
        return data
    }
}

actor DownloadCounter {
    private(set) var count = 0
    func increment() { count += 1 }
}

let downloads = DownloadCounter()
let loader = ImageLoader { url in
    await downloads.increment()
    try await Task.sleep(for: .milliseconds(20))
    return Data(repeating: 0, count: 4_096)
}

let avatar = URL(string: "https://cdn.example.com/avatars/sam.jpg")!
async let header = loader.data(for: avatar)
async let comment = loader.data(for: avatar)
async let sidebar = loader.data(for: avatar)
let sizes = try await [header, comment, sidebar].map(\.count)
print("Three views got \(sizes) bytes from \(await downloads.count) download")

let later = try await loader.data(for: avatar)
print("A fourth view got \(later.count) bytes; downloads so far: \(await downloads.count)")
