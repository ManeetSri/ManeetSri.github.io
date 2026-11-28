import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Requests = CreationalRequestBuilder

private let api = URL(string: "https://api.example.com")!

private struct NewOrder: Encodable {
    let quantity: Int
    let name: String
}

@Suite struct CreationalRequestBuilderTests {
    @Test("With nothing set, it builds a GET for the base URL's root")
    func defaults() throws {
        let request = try Requests.Builder(baseURL: api).build()
        #expect(request.url?.absoluteString == "https://api.example.com/")
        #expect(request.httpMethod == "GET")
        #expect(request.httpBody == nil)
        #expect(request.timeoutInterval == 60)
        #expect((request.allHTTPHeaderFields ?? [:]).isEmpty)
    }

    @Test("The path is added to the base URL's own path, with no double slash", arguments: [
        ("https://api.example.com", "/orders", "https://api.example.com/orders"),
        ("https://api.example.com/v2", "/orders", "https://api.example.com/v2/orders"),
        ("https://api.example.com/v2/", "/orders/42", "https://api.example.com/v2/orders/42"),
    ])
    func joinsPaths(base: String, path: String, expected: String) throws {
        let request = try Requests.Builder(baseURL: URL(string: base)!).path(path).build()
        #expect(request.url?.absoluteString == expected)
    }

    @Test("Query items keep their order and repeats, and nil values are left out")
    func queryItems() throws {
        let request = try Requests.Builder(baseURL: api)
            .path("/search")
            .query("tag", "green")
            .query("page", nil)
            .query("tag", "loose")
            .build()
        #expect(request.url?.absoluteString == "https://api.example.com/search?tag=green&tag=loose")
    }

    @Test("Query values are encoded so a server reads them back exactly, + included")
    func encodesQueryValues() throws {
        let request = try Requests.Builder(baseURL: api)
            .path("/search")
            .query("q", "tea + cake")
            .query("filter", "a&b=c")
            .build()
        #expect(request.url?.absoluteString == "https://api.example.com/search?q=tea%20%2B%20cake&filter=a%26b%3Dc")
    }

    @Test("A header set twice keeps the last value, whatever the letter case")
    func headers() throws {
        let request = try Requests.Builder(baseURL: api)
            .header("Accept", "text/plain")
            .header("X-Request-ID", "r-1")
            .header("accept", "application/json")
            .build()
        #expect(request.value(forHTTPHeaderField: "ACCEPT") == "application/json")
        #expect(request.value(forHTTPHeaderField: "x-request-id") == "r-1")
        #expect(request.allHTTPHeaderFields?.count == 2)
    }

    @Test("A JSON body is encoded with sorted keys and labelled as JSON")
    func jsonBody() throws {
        let request = try Requests.Builder(baseURL: api)
            .method(.post)
            .path("/orders")
            .jsonBody(NewOrder(quantity: 2, name: "Tea"))
            .build()
        #expect(request.httpMethod == "POST")
        #expect(request.httpBody == Data(#"{"name":"Tea","quantity":2}"#.utf8))
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test("The timeout can be changed")
    func timeout() throws {
        let request = try Requests.Builder(baseURL: api).path("/ping").timeout(10).build()
        #expect(request.timeoutInterval == 10)
        #expect(request.url?.absoluteString == "https://api.example.com/ping")
    }

    @Test("build() refuses a path without a leading slash")
    func rejectsRelativePath() {
        #expect(throws: Requests.BuildError.invalidPath("orders")) {
            try Requests.Builder(baseURL: api).path("orders").build()
        }
    }

    @Test("build() refuses a GET with a body, but allows other methods one")
    func bodyRules() throws {
        let withBody = try Requests.Builder(baseURL: api).path("/orders/7").jsonBody(NewOrder(quantity: 1, name: "Tea"))
        #expect(throws: Requests.BuildError.bodyNotAllowed(.get)) {
            try withBody.build()
        }
        let delete = try withBody.method(.delete).build()
        #expect(delete.httpMethod == "DELETE")
        #expect(delete.httpBody != nil)
    }

    @Test("Branches of a shared base builder don't affect each other or the base")
    func branching() throws {
        let base = Requests.Builder(baseURL: api).header("Authorization", "Bearer abc")
        let orders = base.path("/orders").query("page", "2")
        let profile = base.path("/profile").header("Accept-Language", "en-GB")

        let ordersRequest = try orders.build()
        let profileRequest = try profile.build()
        let baseRequest = try base.build()

        #expect(ordersRequest.url?.absoluteString == "https://api.example.com/orders?page=2")
        #expect(ordersRequest.value(forHTTPHeaderField: "Accept-Language") == nil)
        #expect(profileRequest.url?.absoluteString == "https://api.example.com/profile")
        #expect(profileRequest.value(forHTTPHeaderField: "Accept-Language") == "en-GB")
        #expect(profileRequest.value(forHTTPHeaderField: "Authorization") == "Bearer abc")
        #expect(baseRequest.url?.absoluteString == "https://api.example.com/")
        #expect(baseRequest.value(forHTTPHeaderField: "Authorization") == "Bearer abc")
    }
}
