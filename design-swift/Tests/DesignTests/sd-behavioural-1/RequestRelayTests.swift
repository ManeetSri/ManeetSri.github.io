import DesignKit
import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RequestRelayTests {
    typealias Next = RequestRelay.Next

    private let request = URLRequest(url: URL(string: "https://api.example.com/trips")!)

    /// Records "<name> in" on the way to the server and "<name> out" on the way back
    private struct Tracing: RequestRelay.Interceptor {
        let name: String
        let log: Recorder<String>

        func intercept(_ request: URLRequest, next: Next) async throws -> (Data, HTTPURLResponse) {
            await log.record("\(name) in")
            let response = try await next(request)
            await log.record("\(name) out")
            return response
        }
    }

    /// A transport that records each request it's sent and answers 200
    private struct LoggingTransport: HTTPClient {
        let log: Recorder<String>

        func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
            await log.record("transport")
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (Data(), response)
        }
    }

    /// Answers by itself without calling `next`, as a cache or an offline guard would
    private struct ShortCircuit: RequestRelay.Interceptor {
        func intercept(_ request: URLRequest, next: Next) async throws -> (Data, HTTPURLResponse) {
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (Data("cached".utf8), response)
        }
    }

    /// Calls `next` again when the first attempt answers 503
    private struct RetryOnce: RequestRelay.Interceptor {
        func intercept(_ request: URLRequest, next: Next) async throws -> (Data, HTTPURLResponse) {
            let first = try await next(request)
            return first.1.statusCode == 503 ? try await next(request) : first
        }
    }

    /// Sets a header, so the tests can see that changes made upstream reach the transport
    private struct Stamp: RequestRelay.Interceptor {
        let value: String

        func intercept(_ request: URLRequest, next: Next) async throws -> (Data, HTTPURLResponse) {
            var request = request
            let earlier = request.value(forHTTPHeaderField: "X-Trail").map { $0 + "," } ?? ""
            request.setValue(earlier + value, forHTTPHeaderField: "X-Trail")
            return try await next(request)
        }
    }

    private static func body(_ text: String) -> StubHTTPClient.Responder {
        { _ in (Data(text.utf8), 200) }
    }

    @Test("With no interceptors, the request goes straight to the transport")
    func passesThrough() async throws {
        let transport = StubHTTPClient([Self.body("trips")])
        let (data, response) = try await RequestRelay.Pipeline([], transport: transport).send(request)
        #expect(String(decoding: data, as: UTF8.self) == "trips")
        #expect(response.statusCode == 200)
        #expect(await transport.requests.map(\.url) == [request.url])
    }

    @Test("Interceptors run first to last on the way out, and last to first on the way back")
    func runsInOrder() async throws {
        let log = Recorder<String>()
        let pipeline = RequestRelay.Pipeline(
            [Tracing(name: "auth", log: log), Tracing(name: "logging", log: log)],
            transport: LoggingTransport(log: log)
        )
        _ = try await pipeline.send(request)
        #expect(await log.values == ["auth in", "logging in", "transport", "logging out", "auth out"])
    }

    @Test("Changes an interceptor makes to the request reach everything after it")
    func changesFlowDownstream() async throws {
        let transport = StubHTTPClient([Self.body("ok")])
        let pipeline = RequestRelay.Pipeline([Stamp(value: "a"), Stamp(value: "b")], transport: transport)
        _ = try await pipeline.send(request)
        #expect(await transport.requests.first?.value(forHTTPHeaderField: "X-Trail") == "a,b")
    }

    @Test("An interceptor that answers by itself stops the chain")
    func shortCircuits() async throws {
        let log = Recorder<String>()
        let pipeline = RequestRelay.Pipeline(
            [Tracing(name: "outer", log: log), ShortCircuit(), Tracing(name: "inner", log: log)],
            transport: LoggingTransport(log: log)
        )
        let (data, _) = try await pipeline.send(request)
        #expect(String(decoding: data, as: UTF8.self) == "cached")
        #expect(await log.values == ["outer in", "outer out"])
    }

    @Test("An interceptor may call next more than once")
    func callsNextTwice() async throws {
        let transport = StubHTTPClient([{ _ in (Data(), 503) }, Self.body("second try")])
        let pipeline = RequestRelay.Pipeline([RetryOnce()], transport: transport)
        let (data, response) = try await pipeline.send(request)
        #expect(response.statusCode == 200)
        #expect(String(decoding: data, as: UTF8.self) == "second try")
        #expect(await transport.requests.count == 2)
    }

    @Test("Errors from the transport come back through the chain")
    func propagatesErrors() async {
        let transport = StubHTTPClient([{ _ in throw URLError(.notConnectedToInternet) }])
        let pipeline = RequestRelay.Pipeline([Stamp(value: "a")], transport: transport)
        await #expect(throws: URLError(.notConnectedToInternet)) {
            try await pipeline.send(request)
        }
        #expect(await transport.requests.count == 1)
    }

    @Test("DefaultHeader adds a missing header and leaves one that's already set")
    func defaultHeader() async throws {
        let transport = StubHTTPClient([Self.body("ok")])
        let pipeline = RequestRelay.Pipeline([RequestRelay.DefaultHeader("Accept", "application/json")], transport: transport)
        var custom = request
        custom.setValue("image/heic", forHTTPHeaderField: "Accept")
        _ = try await pipeline.send(request)
        _ = try await pipeline.send(custom)
        let sent = await transport.requests.map { $0.value(forHTTPHeaderField: "Accept") }
        #expect(sent == ["application/json", "image/heic"])
    }

    @Test("BearerAuth signs every request with the current token")
    func bearerSigns() async throws {
        let refreshes = Recorder<String>()
        let transport = StubHTTPClient([Self.body("ok")])
        let auth = RequestRelay.BearerAuth(token: { "abc" }, refresh: {
            await refreshes.record("refresh")
            return "new"
        })
        _ = try await RequestRelay.Pipeline([auth], transport: transport).send(request)
        #expect(await transport.requests.map { $0.value(forHTTPHeaderField: "Authorization") } == ["Bearer abc"])
        #expect(await refreshes.values.isEmpty)
    }

    @Test("BearerAuth refreshes once on a 401 and retries with the new token")
    func bearerRefreshes() async throws {
        let refreshes = Recorder<String>()
        let transport = StubHTTPClient([{ _ in (Data(), 401) }, Self.body("trips")])
        let auth = RequestRelay.BearerAuth(token: { "expired" }, refresh: {
            await refreshes.record("refresh")
            return "fresh"
        })
        let (data, response) = try await RequestRelay.Pipeline([auth], transport: transport).send(request)
        #expect(response.statusCode == 200)
        #expect(String(decoding: data, as: UTF8.self) == "trips")
        #expect(await transport.requests.map { $0.value(forHTTPHeaderField: "Authorization") } == ["Bearer expired", "Bearer fresh"])
        #expect(await refreshes.values == ["refresh"])
    }

    @Test("BearerAuth gives up after one retry, and other failures don't trigger a refresh", arguments: [401, 403, 500])
    func bearerGivesUp(status: Int) async throws {
        let refreshes = Recorder<String>()
        let transport = StubHTTPClient(status: status)
        let auth = RequestRelay.BearerAuth(token: { "abc" }, refresh: {
            await refreshes.record("refresh")
            return "new"
        })
        let (_, response) = try await RequestRelay.Pipeline([auth], transport: transport).send(request)
        #expect(response.statusCode == status)
        #expect(await transport.requests.count == (status == 401 ? 2 : 1))
        #expect(await refreshes.values.count == (status == 401 ? 1 : 0))
    }
}
