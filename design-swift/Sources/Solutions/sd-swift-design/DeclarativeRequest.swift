// Reference solution: A request DSL. Every builder method works on [Part], so the compiler's rewrite of
// the closure (one buildExpression per line, buildOptional for if, buildEither for if–else, buildArray
// for for) only ever concatenates lists. Building the URLRequest is then one ordered pass over the parts.
import Foundation

public enum DeclarativeRequest {
    public enum Method: String, Sendable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    public enum Part: Equatable, Sendable {
        case method(Method)
        case path(String)
        case query(name: String, value: String)
        case header(name: String, value: String)
        case body(Data)
    }

    public struct Path: Sendable {
        public let segments: [String]

        public init(_ segments: String...) {
            self.segments = segments
        }
    }

    public struct Query: Sendable {
        public let name: String
        public let value: String

        public init(_ name: String, _ value: String) {
            self.name = name
            self.value = value
        }
    }

    public struct Header: Sendable {
        public let name: String
        public let value: String

        public init(_ name: String, _ value: String) {
            self.name = name
            self.value = value
        }
    }

    public struct Body: Sendable {
        public let data: Data
        public let contentType: String

        public init(_ data: Data, contentType: String = "application/json") {
            self.data = data
            self.contentType = contentType
        }
    }

    @resultBuilder
    public enum Builder {
        public static func buildExpression(_ method: Method) -> [Part] {
            [.method(method)]
        }

        public static func buildExpression(_ path: Path) -> [Part] {
            path.segments.map(Part.path)
        }

        public static func buildExpression(_ query: Query) -> [Part] {
            [.query(name: query.name, value: query.value)]
        }

        public static func buildExpression(_ header: Header) -> [Part] {
            [.header(name: header.name, value: header.value)]
        }

        public static func buildExpression(_ body: Body) -> [Part] {
            [.header(name: "Content-Type", value: body.contentType), .body(body.data)]
        }

        public static func buildBlock(_ parts: [Part]...) -> [Part] {
            parts.flatMap { $0 }
        }

        public static func buildOptional(_ parts: [Part]?) -> [Part] {
            parts ?? []
        }

        public static func buildEither(first parts: [Part]) -> [Part] {
            parts
        }

        public static func buildEither(second parts: [Part]) -> [Part] {
            parts
        }

        public static func buildArray(_ parts: [[Part]]) -> [Part] {
            parts.flatMap { $0 }
        }
    }

    public static func parts(@Builder _ build: () -> [Part]) -> [Part] {
        build()
    }

    public static func request(_ base: URL, @Builder _ build: () -> [Part]) -> URLRequest {
        var url = base
        var method = Method.get
        var query: [URLQueryItem] = []
        var headers: [(String, String)] = []
        var body: Data?

        for part in build() {
            switch part {
            case .method(let chosen): method = chosen
            case .path(let segment): url.append(path: segment)
            case .query(let name, let value): query.append(URLQueryItem(name: name, value: value))
            case .header(let name, let value): headers.append((name, value))
            case .body(let data): body = data
            }
        }

        // Only add a query when there is one: an empty list would leave a trailing "?"
        if !query.isEmpty, var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.queryItems = (components.queryItems ?? []) + query
            url = components.url ?? url
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        for (name, value) in headers {
            request.setValue(value, forHTTPHeaderField: name)
        }
        request.httpBody = body
        return request
    }
}
