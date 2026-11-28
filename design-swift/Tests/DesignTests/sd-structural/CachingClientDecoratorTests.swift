import DesignKit
import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CachingClientDecoratorTests {
    typealias Cache = CachingClientDecorator.CachingHTTPClient<TestClock>

    private func request(_ path: String, method: String = "GET", policy: URLRequest.CachePolicy = .useProtocolCachePolicy) -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.example.com\(path)")!, cachePolicy: policy)
        request.httpMethod = method
        return request
    }

    /// A server whose answer changes every time it's asked: "v1", then "v2", and so on
    private func changingServer() -> StubHTTPClient {
        StubHTTPClient((1...9).map { version in { _ in (Data("v\(version)".utf8), 200) } })
    }

    private func body(_ data: Data) -> String {
        String(decoding: data, as: UTF8.self)
    }

    @Test("A repeated GET is answered from memory while it's fresh")
    func freshHit() async throws {
        let server = changingServer()
        let clock = TestClock()
        let cache = Cache(wrapping: server, ttl: .seconds(60), clock: clock)
        let (first, _) = try await cache.send(request("/feed"))
        clock.advance(by: .seconds(59))
        let (second, response) = try await cache.send(request("/feed"))
        #expect(body(first) == "v1")
        #expect(body(second) == "v1")
        #expect(response.statusCode == 200)
        #expect(await server.requests.count == 1)
    }

    @Test("Once the time to live is up, it fetches again and caches the new answer")
    func expiry() async throws {
        let server = changingServer()
        let clock = TestClock()
        let cache = Cache(wrapping: server, ttl: .seconds(60), clock: clock)
        _ = try await cache.send(request("/feed"))
        clock.advance(by: .seconds(60))
        let (refreshed, _) = try await cache.send(request("/feed"))
        let (again, _) = try await cache.send(request("/feed"))
        #expect(body(refreshed) == "v2")
        #expect(body(again) == "v2")
        #expect(await server.requests.count == 2)
    }

    @Test("Each URL has its own entry")
    func perURL() async throws {
        let server = changingServer()
        let cache = Cache(wrapping: server, ttl: .seconds(60), clock: TestClock())
        let (feed, _) = try await cache.send(request("/feed"))
        let (profile, _) = try await cache.send(request("/profile"))
        let (feedAgain, _) = try await cache.send(request("/feed"))
        #expect([body(feed), body(profile), body(feedAgain)] == ["v1", "v2", "v1"])
        #expect(await server.requests.count == 2)
    }

    @Test("Error statuses are passed on, not cached")
    func errorStatuses() async throws {
        let server = StubHTTPClient([{ _ in (Data(), 503) }, { _ in (Data(), 404) }, { _ in (Data("ok".utf8), 200) }])
        let cache = Cache(wrapping: server, ttl: .seconds(60), clock: TestClock())
        var statuses: [Int] = []
        for _ in 1...4 {
            statuses.append(try await cache.send(request("/feed")).1.statusCode)
        }
        #expect(statuses == [503, 404, 200, 200])
        #expect(await server.requests.count == 3)
    }

    @Test("Thrown errors are passed on, not cached")
    func thrownErrors() async throws {
        let server = StubHTTPClient([{ _ in throw URLError(.notConnectedToInternet) }, { _ in (Data("v1".utf8), 200) }])
        let cache = Cache(wrapping: server, ttl: .seconds(60), clock: TestClock())
        await #expect(throws: URLError.self) {
            try await cache.send(request("/feed"))
        }
        let (second, _) = try await cache.send(request("/feed"))
        let (third, _) = try await cache.send(request("/feed"))
        #expect(body(second) == "v1")
        #expect(body(third) == "v1")
        #expect(await server.requests.count == 2)
    }

    @Test("Other methods go straight through, and drop the cached copy of their URL")
    func otherMethods() async throws {
        let server = changingServer()
        let cache = Cache(wrapping: server, ttl: .seconds(60), clock: TestClock())
        _ = try await cache.send(request("/cart"))
        let (posted, _) = try await cache.send(request("/cart", method: "POST"))
        let (postedAgain, _) = try await cache.send(request("/cart", method: "POST"))
        let (afterPost, _) = try await cache.send(request("/cart"))
        let (cached, _) = try await cache.send(request("/cart"))
        _ = try await cache.send(request("/cart", method: "DELETE"))
        let (afterDelete, _) = try await cache.send(request("/cart"))
        #expect([body(posted), body(postedAgain), body(afterPost), body(cached), body(afterDelete)] == ["v2", "v3", "v4", "v4", "v6"])
        #expect(await server.requests.count == 6)
    }

    @Test("Reloading ignores the cache, then refreshes it")
    func reload() async throws {
        let server = changingServer()
        let cache = Cache(wrapping: server, ttl: .seconds(60), clock: TestClock())
        _ = try await cache.send(request("/feed"))
        let (reloaded, _) = try await cache.send(request("/feed", policy: .reloadIgnoringLocalCacheData))
        let (afterReload, _) = try await cache.send(request("/feed"))
        #expect(body(reloaded) == "v2")
        #expect(body(afterReload) == "v2")
        #expect(await server.requests.count == 2)
    }

    @Test("removeAll forgets every response")
    func removeAll() async throws {
        let server = changingServer()
        let cache = Cache(wrapping: server, ttl: .seconds(60), clock: TestClock())
        _ = try await cache.send(request("/feed"))
        await cache.removeAll()
        let (afterSignOut, _) = try await cache.send(request("/feed"))
        #expect(body(afterSignOut) == "v2")
        #expect(await server.requests.count == 2)
    }

    @Test("Requests reach the wrapped client unchanged")
    func passesRequestsThrough() async throws {
        let server = changingServer()
        let cache = Cache(wrapping: server, ttl: .seconds(60), clock: TestClock())
        var original = request("/feed")
        original.setValue("Bearer abc", forHTTPHeaderField: "Authorization")
        original.setValue("application/json", forHTTPHeaderField: "Accept")
        _ = try await cache.send(original)
        let sent = try #require(await server.requests.first)
        #expect(sent.url == original.url)
        #expect(sent.value(forHTTPHeaderField: "Authorization") == "Bearer abc")
        #expect(sent.value(forHTTPHeaderField: "Accept") == "application/json")
    }
}
