import Foundation

/// The one thing a networking layer needs from the network. Production code wraps URLSession;
/// tests use `StubHTTPClient`, so nothing touches the real network.
public protocol HTTPClient: Sendable {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

extension URLSession: HTTPClient {
    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        return (data, http)
    }
}

/// Answers requests from a script of responses and records every request it was sent
public actor StubHTTPClient: HTTPClient {
    public typealias Responder = @Sendable (URLRequest) throws -> (Data, Int)

    private var responders: [Responder]
    public private(set) var requests: [URLRequest] = []

    /// Each request takes the next responder; the last one answers everything after it
    public init(_ responders: [Responder]) {
        self.responders = responders
    }

    /// Always the same status and body
    public init(status: Int = 200, body: Data = Data()) {
        self.responders = [{ _ in (body, status) }]
    }

    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requests.append(request)
        let responder = responders.count > 1 ? responders.removeFirst() : responders[0]
        let (data, status) = try responder(request)
        let url = request.url ?? URL(string: "https://example.invalid")!
        let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: "HTTP/1.1", headerFields: nil)!
        return (data, response)
    }
}
