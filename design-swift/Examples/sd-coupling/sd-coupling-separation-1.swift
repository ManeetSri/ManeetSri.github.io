// Generated from src/dsa/design/content/lessons/sd-coupling/sd-coupling-separation.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Request: Sendable {
    var path: String
    var headers: [String: String] = [:]
}

struct Response: Sendable {
    let status: Int
}

protocol HTTPClient: Sendable {
    func send(_ request: Request) async throws -> Response
}

// The transport sends requests. It knows nothing about tokens or logs.
struct StubTransport: HTTPClient {
    func send(_ request: Request) async throws -> Response {
        Response(status: request.headers["Authorization"] == nil ? 401 : 200)
    }
}

// Each concern wraps any client and adds exactly one thing
struct AuthenticatedClient: HTTPClient {
    let wrapped: any HTTPClient
    let token: @Sendable () async -> String

    func send(_ request: Request) async throws -> Response {
        var request = request
        request.headers["Authorization"] = "Bearer \(await token())"
        return try await wrapped.send(request)
    }
}

struct LoggingClient: HTTPClient {
    let wrapped: any HTTPClient
    let log: @Sendable (String) -> Void

    func send(_ request: Request) async throws -> Response {
        let response = try await wrapped.send(request)
        log("\(request.path) → \(response.status)")
        return response
    }
}

// The composition root decides which concerns apply, in one place
let log: @Sendable (String) -> Void = { print($0) }
let signedOut = LoggingClient(wrapped: StubTransport(), log: log)
let signedIn = LoggingClient(wrapped: AuthenticatedClient(wrapped: StubTransport(), token: { "abc123" }), log: log)

_ = try await signedOut.send(Request(path: "/me"))
_ = try await signedIn.send(Request(path: "/me"))
