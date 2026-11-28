// Kata: A request DSL (D06 · Result builders and DSLs)
import Foundation

public enum DeclarativeRequest {
    public enum Method: String, Sendable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    /// One change to a request. The builder turns each line of a request closure into parts, in order.
    public enum Part: Equatable, Sendable {
        case method(Method)
        /// One path segment, appended to the URL
        case path(String)
        case query(name: String, value: String)
        case header(name: String, value: String)
        case body(Data)
    }

    // The words of the DSL. These are finished: each one only holds what you wrote.

    /// Path segments, appended in order: `Path("v1", "orders")`
    public struct Path: Sendable {
        public let segments: [String]

        public init(_ segments: String...) {
            self.segments = segments
        }
    }

    /// One query item: `Query("page", "2")`
    public struct Query: Sendable {
        public let name: String
        public let value: String

        public init(_ name: String, _ value: String) {
            self.name = name
            self.value = value
        }
    }

    /// One header: `Header("Accept", "application/json")`
    public struct Header: Sendable {
        public let name: String
        public let value: String

        public init(_ name: String, _ value: String) {
            self.name = name
            self.value = value
        }
    }

    /// The body, and the Content-Type header that describes it
    public struct Body: Sendable {
        public let data: Data
        public let contentType: String

        public init(_ data: Data, contentType: String = "application/json") {
            self.data = data
            self.contentType = contentType
        }
    }

    /// Turns the lines of a request closure into parts. Every method the DSL needs is declared;
    /// write their bodies.
    @resultBuilder
    public enum Builder {
        public static func buildExpression(_ method: Method) -> [Part] {
            // Write your solution here, then run:
            // swift test --filter DeclarativeRequestTests
            []
        }

        public static func buildExpression(_ path: Path) -> [Part] {
            []
        }

        public static func buildExpression(_ query: Query) -> [Part] {
            []
        }

        public static func buildExpression(_ header: Header) -> [Part] {
            []
        }

        public static func buildExpression(_ body: Body) -> [Part] {
            []
        }

        public static func buildBlock(_ parts: [Part]...) -> [Part] {
            []
        }

        public static func buildOptional(_ parts: [Part]?) -> [Part] {
            []
        }

        public static func buildEither(first parts: [Part]) -> [Part] {
            []
        }

        public static func buildEither(second parts: [Part]) -> [Part] {
            []
        }

        public static func buildArray(_ parts: [[Part]]) -> [Part] {
            []
        }
    }

    /// The parts a closure builds, in order: handy for testing the builder on its own
    public static func parts(@Builder _ build: () -> [Part]) -> [Part] {
        build()
    }

    /// A URLRequest for `base` with the parts applied in order: GET unless a Method says otherwise (the
    /// last one wins), path segments appended, query items in order, headers set (a later value for the
    /// same name replaces an earlier one) and the last body.
    public static func request(_ base: URL, @Builder _ build: () -> [Part]) -> URLRequest {
        URLRequest(url: base)
    }
}
