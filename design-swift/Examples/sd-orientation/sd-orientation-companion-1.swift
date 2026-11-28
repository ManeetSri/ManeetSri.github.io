// Generated from src/dsa/design/content/lessons/sd-orientation/sd-orientation-companion.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

/// The same shape as DesignKit's `HTTPClient`: all a networking layer needs from the network
protocol HTTPClient: Sendable {
    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

/// A small `StubHTTPClient`: answers from a script and records every path it was sent
actor StubClient: HTTPClient {
    private var script: [(status: Int, body: String)]
    private(set) var paths: [String] = []

    init(_ script: [(status: Int, body: String)]) {
        self.script = script
    }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        paths.append(request.url?.path() ?? "")
        let (status, body) = script.count > 1 ? script.removeFirst() : script[0]
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
        return (Data(body.utf8), response)
    }
}

struct Forecast: Decodable {
    let place: String
    let celsius: Int
}

enum ForecastError: Error {
    case unavailable(status: Int)
}

/// The code under test never mentions URLSession: it's handed a client
struct ForecastLoader {
    let client: any HTTPClient

    func forecast(for place: String) async throws -> Forecast {
        let request = URLRequest(url: URL(string: "https://api.example.com/forecast/\(place)")!)
        var (data, response) = try await client.send(request)
        if response.statusCode >= 500 {
            // One retry for a server error. A real policy waits first: you'll build one in D14.
            (data, response) = try await client.send(request)
        }
        guard response.statusCode == 200 else { throw ForecastError.unavailable(status: response.statusCode) }
        return try JSONDecoder().decode(Forecast.self, from: data)
    }
}

let flaky = StubClient([
    (status: 503, body: ""),
    (status: 200, body: #"{"place": "London", "celsius": 14}"#),
])
let forecast = try await ForecastLoader(client: flaky).forecast(for: "london")
print("\(forecast.place): \(forecast.celsius)°C")
print("Sent:", await flaky.paths)

let down = StubClient([(status: 503, body: "")])
do {
    _ = try await ForecastLoader(client: down).forecast(for: "paris")
} catch {
    print("Failed:", error)
}
print("Sent:", await down.paths)
