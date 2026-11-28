import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Method = DeclarativeRequest.Method
private typealias Path = DeclarativeRequest.Path
private typealias Query = DeclarativeRequest.Query
private typealias Header = DeclarativeRequest.Header
private typealias Body = DeclarativeRequest.Body

private let base = URL(string: "https://api.example.com")!

@Suite struct DeclarativeRequestTests {
    @Test("Each line becomes parts, in the order it's written")
    func partsInOrder() {
        let parts = DeclarativeRequest.parts {
            Method.post
            Path("v1", "orders")
            Query("page", "2")
            Header("Accept", "application/json")
        }
        #expect(parts == [
            .method(.post),
            .path("v1"),
            .path("orders"),
            .query(name: "page", value: "2"),
            .header(name: "Accept", value: "application/json"),
        ])
    }

    @Test("An if without an else adds its parts only when the condition holds", arguments: [true, false])
    func optionalParts(includeDrafts: Bool) {
        let parts = DeclarativeRequest.parts {
            Path("orders")
            if includeDrafts {
                Query("drafts", "true")
            }
        }
        let expected: [DeclarativeRequest.Part] = includeDrafts
            ? [.path("orders"), .query(name: "drafts", value: "true")]
            : [.path("orders")]
        #expect(parts == expected)
    }

    @Test("An if–else adds the parts of exactly one branch", arguments: [true, false])
    func eitherBranch(signedIn: Bool) {
        let parts = DeclarativeRequest.parts {
            if signedIn {
                Header("Authorization", "Bearer abc")
                Path("me")
            } else {
                Path("guest")
            }
        }
        let expected: [DeclarativeRequest.Part] = signedIn
            ? [.header(name: "Authorization", value: "Bearer abc"), .path("me")]
            : [.path("guest")]
        #expect(parts == expected)
    }

    @Test("A for loop adds parts for every element")
    func loops() {
        let ids = ["a1", "b2", "c3"]
        let parts = DeclarativeRequest.parts {
            Path("products")
            for id in ids {
                Query("id", id)
            }
        }
        #expect(parts == [.path("products"), .query(name: "id", value: "a1"), .query(name: "id", value: "b2"), .query(name: "id", value: "c3")])
    }

    @Test("Builds the URL from the base, the path segments and the query items")
    func url() {
        let request = DeclarativeRequest.request(base) {
            Path("v1", "search")
            Query("q", "green tea")
            Query("page", "2")
            Query("tag", "loose")
            Query("tag", "organic")
        }
        #expect(request.url?.absoluteString == "https://api.example.com/v1/search?q=green%20tea&page=2&tag=loose&tag=organic")
    }

    @Test("No query items means no question mark")
    func noQuery() {
        let request = DeclarativeRequest.request(base) {
            Path("v1", "me")
        }
        #expect(request.url?.absoluteString == "https://api.example.com/v1/me")
    }

    @Test("GET unless a method says otherwise, and the last method wins")
    func methods() {
        let plain = DeclarativeRequest.request(base) {
            Path("feed")
        }
        let changed = DeclarativeRequest.request(base) {
            Method.put
            Path("cart")
            Method.delete
        }
        #expect(plain.httpMethod == "GET")
        #expect(plain.url?.absoluteString == "https://api.example.com/feed")
        #expect(changed.httpMethod == "DELETE")
    }

    @Test("Sets headers and the body; a body brings its Content-Type, and a later header replaces an earlier one")
    func headersAndBody() {
        let json = Data(#"{"sku":"mug","quantity":2}"#.utf8)
        let request = DeclarativeRequest.request(base) {
            Method.post
            Path("cart", "items")
            Header("Accept", "text/plain")
            Body(json)
            Header("Accept", "application/json")
        }
        #expect(request.httpMethod == "POST")
        #expect(request.url?.absoluteString == "https://api.example.com/cart/items")
        #expect(request.httpBody == json)
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test("Everything together: conditions and loops inside a real request")
    func together() {
        let ids = ["7", "9"]
        let expanded = true
        let request = DeclarativeRequest.request(base) {
            Path("v2", "orders")
            for id in ids {
                Query("id", id)
            }
            if expanded {
                Query("expand", "items")
            } else {
                Query("expand", "none")
            }
            Header("Accept-Language", "en-GB")
        }
        #expect(request.url?.absoluteString == "https://api.example.com/v2/orders?id=7&id=9&expand=items")
        #expect(request.value(forHTTPHeaderField: "Accept-Language") == "en-GB")
    }
}
