// Reference solution: Request builder. The builder is a struct, and every method copies it, changes
// one part and returns the copy, so a configured base builder can be branched safely. Parts are kept
// as plain values (an ordered list of query items and of headers) and only turned into a URLRequest,
// after validation, in build().
import Foundation

public enum CreationalRequestBuilder {
    public enum Method: String, Sendable {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }

    public enum BuildError: Error, Equatable, Sendable {
        case invalidPath(String)
        case bodyNotAllowed(Method)
    }

    public struct Builder: Sendable {
        private let baseURL: URL
        private var method = Method.get
        private var path = "/"
        private var queryItems: [(name: String, value: String)] = []
        private var headers: [(name: String, value: String)] = []
        private var body: Data?
        private var timeoutInterval: TimeInterval = 60

        public init(baseURL: URL) {
            self.baseURL = baseURL
        }

        public func method(_ method: Method) -> Builder {
            changing { $0.method = method }
        }

        public func path(_ path: String) -> Builder {
            changing { $0.path = path }
        }

        public func query(_ name: String, _ value: String?) -> Builder {
            guard let value else { return self }
            return changing { $0.queryItems.append((name, value)) }
        }

        public func header(_ name: String, _ value: String) -> Builder {
            changing { builder in
                builder.headers.removeAll { $0.name.caseInsensitiveCompare(name) == .orderedSame }
                builder.headers.append((name, value))
            }
        }

        public func jsonBody(_ value: some Encodable) throws -> Builder {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let data = try encoder.encode(value)
            return changing { $0.body = data }.header("Content-Type", "application/json")
        }

        public func timeout(_ seconds: TimeInterval) -> Builder {
            changing { $0.timeoutInterval = seconds }
        }

        public func build() throws(BuildError) -> URLRequest {
            guard path.hasPrefix("/") else { throw .invalidPath(path) }
            if method == .get, body != nil { throw .bodyNotAllowed(method) }

            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) ?? URLComponents()
            var basePath = components.percentEncodedPath
            while basePath.hasSuffix("/") { basePath.removeLast() }
            components.percentEncodedPath = basePath + path
            if !queryItems.isEmpty {
                // URLComponents leaves "+" alone, and servers often read it as a space, so encode it here
                components.percentEncodedQueryItems = queryItems.map {
                    URLQueryItem(name: Self.encode($0.name), value: Self.encode($0.value))
                }
            }

            var request = URLRequest(url: components.url ?? baseURL)
            request.httpMethod = method.rawValue
            request.timeoutInterval = timeoutInterval
            request.httpBody = body
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.name)
            }
            return request
        }

        private func changing(_ change: (inout Builder) -> Void) -> Builder {
            var copy = self
            change(&copy)
            return copy
        }

        private static let queryValueAllowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "+&=#"))

        private static func encode(_ text: String) -> String {
            text.addingPercentEncoding(withAllowedCharacters: queryValueAllowed) ?? text
        }
    }
}
