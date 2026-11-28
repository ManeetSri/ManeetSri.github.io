// Generated from src/dsa/design/content/lessons/sd-behavioural-1/sd-behavioural-chain-of-responsibility.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Request: Sendable {
    var path: String
    var headers: [String: String] = [:]
}

struct Response: Sendable {
    var status: Int
    var body: String
}

/// The rest of the chain, as seen from one interceptor
typealias Next = @Sendable (Request) async throws -> Response

protocol Interceptor: Sendable {
    func intercept(_ request: Request, next: Next) async throws -> Response
}

struct Logging: Interceptor {
    func intercept(_ request: Request, next: Next) async throws -> Response {
        print("  → GET \(request.path)")
        let response = try await next(request)
        print("  ← \(response.status)")
        return response
    }
}

struct BearerToken: Interceptor {
    let token: String

    func intercept(_ request: Request, next: Next) async throws -> Response {
        var request = request
        request.headers["Authorization"] = "Bearer \(token)"
        return try await next(request)
    }
}

struct RetryOnce: Interceptor {
    func intercept(_ request: Request, next: Next) async throws -> Response {
        let response = try await next(request)
        return response.status == 503 ? try await next(request) : response
    }
}

/// A server that's overloaded for the first request it sees
actor FlakyServer {
    private var requests = 0

    func handle(_ request: Request) -> Response {
        requests += 1
        guard request.headers["Authorization"] != nil else { return Response(status: 401, body: "") }
        return requests == 1 ? Response(status: 503, body: "") : Response(status: 200, body: "3 trips")
    }
}

/// Wraps the transport in each interceptor, last first, so the first one runs outermost
func makeClient(_ interceptors: [any Interceptor], server: FlakyServer) -> Next {
    let transport: Next = { request in await server.handle(request) }
    return interceptors.reversed().reduce(transport) { next, interceptor in
        { request in try await interceptor.intercept(request, next: next) }
    }
}

print("Logging outside the retry:")
let quiet = makeClient([Logging(), RetryOnce(), BearerToken(token: "abc")], server: FlakyServer())
print("  got \(try await quiet(Request(path: "/trips")).body)")

print("Logging inside the retry:")
let chatty = makeClient([RetryOnce(), Logging(), BearerToken(token: "abc")], server: FlakyServer())
print("  got \(try await chatty(Request(path: "/trips")).body)")
