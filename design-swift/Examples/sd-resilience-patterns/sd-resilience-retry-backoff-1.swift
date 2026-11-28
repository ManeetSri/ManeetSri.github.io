// Generated from src/dsa/design/content/lessons/sd-resilience-patterns/sd-resilience-retry-backoff.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct HTTPStatusError: Error {
    let status: Int
}

struct RetryPolicy {
    var maxAttempts = 4
    var base = 0.5
    var cap = 8.0

    // No jitter here, so the output is the same every run; production code adds it
    func delay(beforeRetry retry: Int) -> Double {
        min(cap, base * pow(2, Double(retry)))
    }

    // Transient failures are worth another try; everything else fails the same way again
    func shouldRetry(_ error: any Error) -> Bool {
        if let urlError = error as? URLError {
            return [.timedOut, .networkConnectionLost, .cannotConnectToHost].contains(urlError.code)
        }
        if let http = error as? HTTPStatusError {
            return [408, 429, 502, 503, 504].contains(http.status)
        }
        return false
    }
}

func withRetries<T: Sendable>(_ policy: RetryPolicy, sleep: @Sendable (Double) async throws -> Void, _ operation: @Sendable () async throws -> T) async throws -> T {
    var retries = 0
    while true {
        do {
            return try await operation()
        } catch {
            guard retries + 1 < policy.maxAttempts, policy.shouldRetry(error) else { throw error }
            try await sleep(policy.delay(beforeRetry: retries))
            retries += 1
        }
    }
}

// A fake upload endpoint that fails in a scripted way, and a log of the waits instead of real sleeps
actor ScriptedServer {
    private var script: [(any Error)?]
    private(set) var attempts = 0

    init(_ script: [(any Error)?]) {
        self.script = script
    }

    func upload() throws -> String {
        attempts += 1
        if let failure = script.count > 1 ? script.removeFirst() : script[0] {
            throw failure
        }
        return "uploaded"
    }
}

actor Waits {
    private(set) var seconds: [Double] = []
    func record(_ delay: Double) { seconds.append(delay) }
}

func attempt(_ name: String, _ script: [(any Error)?]) async {
    let server = ScriptedServer(script)
    let waits = Waits()
    do {
        let result = try await withRetries(RetryPolicy(), sleep: { await waits.record($0) }) {
            try await server.upload()
        }
        print("\(name): \(result) · attempts: \(await server.attempts) · waits: \(await waits.seconds)")
    } catch {
        print("\(name): gave up · attempts: \(await server.attempts) · waits: \(await waits.seconds)")
    }
}

await attempt("Two blips", [URLError(.timedOut), URLError(.networkConnectionLost), nil])
await attempt("Server down", [HTTPStatusError(status: 503)])
await attempt("Not found", [HTTPStatusError(status: 404)])
